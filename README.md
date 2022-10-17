# Route53 Events Lambda

# Task
Build terraform code to deploy the following:
* EventBridge rule to capture all route53 events (excluding failed requests)
* SQS queue that captures that EventBridge rule
* Lambda (Golang) that captures messages from the SQS queue
* The code should only process the ChangeResourceRecordSets calls and drop everything else
* Lambda should add a new json key to the root of the original event (“Author”: “Vladislav”)
* And writes the whole message to Cloudwatch

## Requirements
* go 1.17
* terraform 1.3.2

## Deployment
```sh
terraform init
terraform apply
```