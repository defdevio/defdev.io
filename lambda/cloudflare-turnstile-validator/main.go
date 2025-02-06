package main

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"

	lambdav2 "github.com/aws/aws-sdk-go-v2/service/lambda"
)

type Event struct {
	ClientName             string `json:"clientName"`
	EmailAddress           string `json:"emailAddress"`
	PhoneNumber            string `json:"phoneNumber,omitempty"`
	ProjectDescription     string `json:"projectDescription"`
	PreferredCloudProvider string `json:"preferredCloudProvider"`
	CfTurnstileResponse    string `json:"cf-turnstile-response"`
}

type CfTurnstileRequest struct {
	Secret   string `json:"secret"`
	Response string `json:"response"`
	RemoteIp string `json:"remoteip"`
}

type CfTurnstileResponse struct {
	Success     bool          `json:"success"`
	ChallengeTs time.Time     `json:"challenge_ts"`
	Hostname    string        `json:"hostname"`
	ErrorCodes  []interface{} `json:"error-codes"`
	Action      string        `json:"action"`
	Cdata       string        `json:"cdata"`
	Metadata    struct {
		EphemeralID string `json:"ephemeral_id"`
	} `json:"metadata"`
}

type CfSecret struct {
	SecretKey string `json:"secret-key"`
}

type Email struct {
	ClientName             string `json:"clientName"`
	EmailAddress           string `json:"emailAddress"`
	PhoneNumber            string `json:"phoneNumber,omitempty"`
	ProjectDescription     string `json:"projectDescription"`
	PreferredCloudProvider string `json:"preferredCloudProvider"`
}

const (
	cfSecretId      = "cloudflare-turnstile-widget"
	cfSiteVerify    = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
	emailerFunction = "emailer"
)

var (
	secretsClient *secretsmanager.Client
	lambdaClient  *lambdav2.Client
	initCtx       = context.Background()
)

func init() {
	cfg, err := config.LoadDefaultConfig(initCtx)
	if err != nil {
		panic(err)
	}

	secretsClient = secretsmanager.NewFromConfig(cfg)
	lambdaClient = lambdav2.NewFromConfig(cfg)
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var handlerEvent Event
	if err := json.Unmarshal([]byte(request.Body), &handlerEvent); err != nil {
		log.Printf("failed to unmarshal event: %v", err)
		return events.APIGatewayProxyResponse{}, err
	}

	ip := request.Headers["CF-Connecting-IP"]
	cfApiToken, err := secretsClient.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(cfSecretId),
	})

	if err != nil {
		log.Printf("failed to get secret: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusForbidden,
		}, nil
	}

	var cfSecret CfSecret
	err = json.Unmarshal([]byte(*cfApiToken.SecretString), &cfSecret)
	if err != nil {
		log.Printf("error unmarshaling cfSecret request: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}

	cfTurnstileRequest := &CfTurnstileRequest{
		Secret:   cfSecret.SecretKey,
		Response: handlerEvent.CfTurnstileResponse,
		RemoteIp: ip,
	}

	requestBody, err := json.Marshal(cfTurnstileRequest)
	if err != nil {
		log.Printf("error marshaling cloudflare turnstile request: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}

	req, err := http.NewRequest(http.MethodPost, cfSiteVerify, bytes.NewBuffer(requestBody))
	if err != nil {
		log.Printf("error creating cloudflare turnstile request: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("error sending cloudflare turnstile request: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK {
		respBody, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("error reading cloudflare turnstile response: %v", err)
			return events.APIGatewayProxyResponse{
				StatusCode: http.StatusInternalServerError,
			}, nil
		}

		var cfTurnstileResponse CfTurnstileResponse
		err = json.Unmarshal(respBody, &cfTurnstileResponse)
		if err != nil {
			log.Printf("error unmarshaling cloudflare turnstile request: %v", err)
			return events.APIGatewayProxyResponse{
				StatusCode: http.StatusInternalServerError,
			}, nil
		}

		if cfTurnstileResponse.Success {
			email := &Email{
				ClientName:             handlerEvent.ClientName,
				EmailAddress:           handlerEvent.EmailAddress,
				PhoneNumber:            handlerEvent.PhoneNumber,
				ProjectDescription:     handlerEvent.ProjectDescription,
				PreferredCloudProvider: handlerEvent.PreferredCloudProvider,
			}

			emailPayload, err := json.Marshal(email)
			if err != nil {
				log.Printf("error marshaling email payload: %v", err)
				return events.APIGatewayProxyResponse{
					StatusCode: http.StatusInternalServerError,
				}, nil
			}

			resp, err := lambdaClient.Invoke(ctx, &lambdav2.InvokeInput{
				FunctionName: aws.String(emailerFunction),
				Payload:      emailPayload,
			})
			if err != nil {
				log.Printf("error invoking emailer function: %v", err)
				return events.APIGatewayProxyResponse{
					StatusCode: http.StatusInternalServerError,
				}, nil
			}

			if resp.StatusCode == http.StatusOK {
				return events.APIGatewayProxyResponse{Body: "success: email sent", StatusCode: http.StatusOK}, nil
			}

			return events.APIGatewayProxyResponse{StatusCode: http.StatusInternalServerError}, nil
		}
	}

	return events.APIGatewayProxyResponse{StatusCode: http.StatusForbidden}, nil
}

func main() {
	lambda.Start(handler)
}
