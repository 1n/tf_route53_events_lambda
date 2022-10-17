package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type CloudWatchEvent struct {
	Version    string          `json:"version"`
	ID         string          `json:"id"`
	DetailType string          `json:"detail-type"`
	Source     string          `json:"source"`
	AccountID  string          `json:"account"`
	Time       time.Time       `json:"time"`
	Region     string          `json:"region"`
	Resources  []string        `json:"resources"`
	Detail     json.RawMessage `json:"detail"`

	Author string `json:"author"`
}

type CloudWatchEventDetail struct {
	EventName string `json:"eventName"`
}

var event CloudWatchEvent
var eventDetail CloudWatchEventDetail

func HandleRequest(ctx context.Context, sqsEvent events.SQSEvent) {
	for _, message := range sqsEvent.Records {
		err := json.Unmarshal([]byte(message.Body), &event)
		if err != nil {
			fmt.Println("Could not unmarshal event: ", err)
		}

		err = json.Unmarshal([]byte(event.Detail), &eventDetail)
		if err != nil {
			fmt.Println("Could not unmarshal event detail: ", err)
		}

		if eventDetail.EventName == "ChangeResourceRecordSets" {
			event.Author = os.Getenv("AUTHOR")
			output, err := json.Marshal(event)
			if err != nil {
				log.Fatal("Could not marshal event: ", err)
			}
			fmt.Println(string(output))
		}
	}
}

func main() {
	lambda.Start(HandleRequest)
}
