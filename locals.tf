locals {
  resource_prefix                  = "${var.env}-${var.prefix}"
  step_function_name               = "${local.resource_prefix}-validate-bagit"
  lambda_name_bag_validation       = "${local.resource_prefix}-vb-bag-validation"
  lambda_name_bag_files_validation = "${local.resource_prefix}-vb-bag-files-validation"
  lambda_name_trigger              = "${local.resource_prefix}-vb-trigger"
}
