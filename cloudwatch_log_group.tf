resource "aws_cloudwatch_log_group" "validate_bagit" {
  name = "/aws/vendedlogs/states/${local.step_function_name}-logs"
}
