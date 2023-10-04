variable "env" {
  description = "Name of the environment to deploy"
  type        = string
}

variable "prefix" {
  description = "Transformation Engine prefix"
  type        = string
}

variable "tre_data_bucket" {
  description = "TRE Data Bucket Name"
  type        = string
}

variable "vb_version" {
  description = "Validate BagIt Step Function version (update if Step Function flow or called Lambda function versions change)"
  type        = string

}

variable "vb_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_sqs_sf_trigger          = string
    tre_vb_validate_bagit       = string
    tre_vb_validate_bagit_files = string
  })
}

variable "common_tre_slack_alerts_topic_arn" {
  description = "ARN of the Common TRE Slack Alerts SNS Topic"
  type        = string
}

variable "common_da_eventbus_topic_arn" {
  description = "The TRE eventbus SNS topic ARN"
  type        = string
}

variable "tre_dlq_alerts_lambda_function_name" {
  description = "TRE DLQ Alerts Lambda Function Name"
  type        = string
}

variable "tre_permission_boundary_arn" {
  description = "ARN of the TRE permission boundary policy"
  type        = string
}

variable "ecr_uri_host" {
  description = "The hostname part of the management account ECR repository; e.g. ACCOUNT.dkr.ecr.REGION.amazonaws.com"
  type        = string
}

variable "ecr_uri_repo_prefix" {
  description = "The prefix for Docker image repository names to use; e.g. foo/ in ACCOUNT.dkr.ecr.REGION.amazonaws.com/foo/tre-bar"
  type        = string
}

variable "tdr_s3_export_bucket_kms_arns" {
  description = "arns of kms for sample data bucket used in tests"
  type        = list(string)
}

variable "tdr_s3_export_bucket_arns" {
  description = "tdr s3 export bucket arns"
  type        = list(string)
}
