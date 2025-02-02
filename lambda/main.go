package main

import (
	"context"
	"encoding/json"
	"log"
	"os"
	"strings"

	"github.com/Boostport/mjml-go"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ses"
	"github.com/aws/aws-sdk-go-v2/service/ses/types"
)

var sesClient *ses.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	sesClient = ses.NewFromConfig(cfg)
}

type Email struct {
	ClientName             string `json:"clientName"`
	EmailAddress           string `json:"emailAddress"`
	PhoneNumber            string `json:"phoneNumber,omitempty"`
	ProjectDescription     string `json:"projectDescription"`
	PreferredCloudProvider string `json:"preferredCloudProvider"`
}

func handleRequest(ctx context.Context, event json.RawMessage) error {
	var email Email

	if err := json.Unmarshal(event, &email); err != nil {
		log.Printf("failed to unmarshal event: %v", err)
		return err
	}

	templateBytes, err := os.ReadFile("mjml/email.mjml")
	if err != nil {
		log.Printf("failed to read file: %v", err)
		return err
	}

	template := string(templateBytes)
	template = strings.Replace(template, "[[ClientName]]", email.ClientName, 1)
	template = strings.Replace(template, "[[ProjectDescription]]", email.ProjectDescription, 1)
	template = strings.Replace(template, "[[EmailContact]]", email.EmailAddress, 1)
	template = strings.Replace(template, "[[PhoneContact]]", email.PhoneNumber, 1)
	template = strings.Replace(template, "[[PreferredCloud]]", email.PreferredCloudProvider, 1)

	rendered, err := mjml.ToHTML(ctx, template)
	if err != nil {
		log.Printf("failed to render mjml template: %v", err)
	}

	out, err := sesClient.SendEmail(ctx, &ses.SendEmailInput{
		Destination: &types.Destination{
			ToAddresses: []string{"inquiries@defdev.io"},
		},
		Message: &types.Message{
			Body: &types.Body{
				Html: &types.Content{
					Data: &rendered,
				},
			},
		},
		Source: aws.String("inquiries@defdev.io"),
	})

	if err != nil {
		log.Printf("failed to send email: %v", err)
		return err
	}

	log.Printf("successfully sent email: message id: %s", *out.MessageId)
	return nil
}

func main() {
	lambda.Start(handleRequest)
}
