resource "aws_sfn_state_machine" "validate_bagit" {
  name     = local.step_function_name
  role_arn = aws_iam_role.validate_bagit.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
    arn_lambda_vb_files_checksum_validation = aws_lambda_function.vb_files_checksum_validation.arn
    arn_sns_topic_validate_bagit_out        = var.notification_topic_arn
  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.validate_bagit.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}
