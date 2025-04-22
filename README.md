# TRE Validate BagIt Step Function

This repository contains the infrastructure as code (IaC) for the **TRE Validate BagIt** Step Function. The Step Function is responsible for coordinating the validation of BagIt files, handling errors, and sending appropriate notifications. It is triggered by messages received on an Amazon SQS queue.

## Overview

The Step Function performs the following tasks:
1. **Trigger**: Starts execution when a message is received on the SQS queue.
2. **Validation**: Invokes a Lambda function to validate BagIt files.
3. **Error Handling**: Handles errors during validation and sends error notifications.
4. **Notifications**: Sends success or failure messages to an Amazon SNS topic.

## Repository Structure

- **`variables.tf`**: Defines input variables for the Terraform configuration, such as environment names, SQS queue names, Lambda function names, and SNS topic ARNs.
- **`sfn.tf`**: Defines the AWS Step Function resource and its configuration, including the state machine definition and logging/tracing settings.
- **`sqs.tf`**: Defines the SQS queues and their policies, including the dead-letter queue (DLQ) and event source mapping for the DLQ to trigger a Lambda function.
- **`templates/step-function-definition.json.tftpl`**: Contains the JSON template for the Step Function definition, specifying the states, transitions, and tasks.

## Workflow

1. **SQS Trigger**:
    - Messages are sent to the primary SQS queue (`tre_vb_in`).
    - If a message fails processing multiple times, it is moved to the dead-letter queue (`tre_vb_in_deadletter`).

2. **Step Function Execution**:
    - The Step Function is triggered by the SQS message.
    - It starts by checking if validation is required.
    - If validation is required, it invokes the `vb_files_checksum_validation` Lambda function.

3. **Error Handling**:
    - If the Lambda function fails, the Step Function catches the error and sends an error notification to the SNS topic.

4. **Notifications**:
    - Depending on the result of the validation, the Step Function sends success or failure messages to the SNS topic.

## Key Components

### SQS Queues
- **Primary Queue**: `tre_vb_in` - Receives messages to trigger the Step Function.
- **Dead-Letter Queue**: `tre_vb_in_deadletter` - Stores messages that fail processing after multiple attempts.

### Lambda Functions
- **Validation Lambda**: `vb_files_checksum_validation` - Validates the BagIt files.
- **DLQ Alerts Lambda**: Processes messages from the dead-letter queue.

### SNS Topic
- **Notification Topic**: Sends notifications about the success or failure of the validation process.

### Step Function
- **State Machine**: Coordinates the validation process, error handling, and notifications.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate permissions.
- An existing SNS topic ARN for notifications.
- Lambda functions deployed for validation and DLQ alerts.

## Deployment

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   