# Step Function Roles and Policies

resource "aws_iam_role" "validate_bagit" {
  name                 = "${local.step_function_name}-role"
  assume_role_policy   = data.aws_iam_policy_document.validate_bagit_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
  inline_policy {
    name   = "${local.step_function_name}-policies"
    policy = data.aws_iam_policy_document.validate_bagit_machine_policies.json
  }
}

data "aws_iam_policy_document" "validate_bagit_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "validate_bagit_machine_policies" {
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid     = "InvokeLambdaPolicy"
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      aws_lambda_function.vb_bagit_checksum_validation.arn,
      aws_lambda_function.vb_files_checksum_validation.arn
    ]
  }
}

# Lambda Roles

resource "aws_iam_role" "validate_bagit_lambda_invoke_role" {
  name                 = "${local.step_function_name}-lambda-invoke-role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
}

resource "aws_iam_role_policy_attachment" "validate_bagit_lambda_role_policy" {
  role       = aws_iam_role.validate_bagit_lambda_invoke_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

data "aws_iam_policy_document" "validate_bagit_lambda_kms_policy_data" {
  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = var.dr_s3_export_bucket_kms_arns
  }
}

resource "aws_iam_policy" "validate_bagit_lambda_kms_policy" {
  name        = "${var.env}-${var.prefix}-validate_bagit-s3-key"
  description = "The KMS key policy for validate bagit lambda"
  policy      = data.aws_iam_policy_document.validate_bagit_lambda_kms_policy_data.json
}

resource "aws_iam_role_policy_attachment" "validate_bagit_lambda_key" {
  role       = aws_iam_role.validate_bagit_lambda_invoke_role.name
  policy_arn = aws_iam_policy.validate_bagit_lambda_kms_policy.arn
}



resource "aws_iam_role" "vb_trigger_lambda" {
  name                 = "${var.env}-${var.prefix}-vb-trigger-lambda-role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
  inline_policy {
    name   = "${var.env}-${var.prefix}-vb-trigger"
    policy = data.aws_iam_policy_document.vb_trigger.json
  }
}

resource "aws_iam_role_policy_attachment" "vb_trigger_lambda_sqs" {
  role       = aws_iam_role.vb_trigger_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# Lambda policy documents

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vb_trigger" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [aws_sfn_state_machine.validate_bagit.arn]
  }
}

# SQS Policies

data "aws_iam_policy_document" "tre_vb_queue_in" {
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
    resources = [
      aws_sqs_queue.tre_vb_in.arn
    ]
  }
}


resource "aws_iam_role_policy_attachment" "tdr_s3_bucket" {
  role       = aws_iam_role.validate_bagit_lambda_invoke_role.name
  policy_arn = aws_iam_policy.s3_tdr_bucket_access_policy.arn
}

resource "aws_iam_policy" "s3_tdr_bucket_access_policy" {
  name        = "${var.env}-${var.prefix}-tdr-s3-policy"
  description = "The s3 policy to allow lambda to read from the tdr transfer bucket"
  policy      = data.aws_iam_policy_document.s3_tdr_bucket_access_policy.json
}

data "aws_iam_policy_document" "s3_tdr_bucket_access_policy" {
  dynamic "statement" {
    for_each = var.tdr_s3_export_bucket_arns
    content {
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      effect  = "Allow"
      resources = [
         statement.value,
        "${statement.value}/*"
      ]
    }
  }
}




