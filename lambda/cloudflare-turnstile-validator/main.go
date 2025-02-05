package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Event struct {
	Test string `json:"test"`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var handlerEvent Event
	if err := json.Unmarshal([]byte(request.Body), &handlerEvent); err != nil {
		log.Printf("failed to unmarshal event: %v", err)
		return events.APIGatewayProxyResponse{}, err
	}

	return events.APIGatewayProxyResponse{Body: handlerEvent.Test, StatusCode: 200}, nil
}

func main() {
	lambda.Start(handler)
}
