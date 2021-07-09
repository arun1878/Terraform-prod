data "aws_s3_bucket_object" "s3bucket" {
  bucket = var.bucket_name
  key    = var.s3_bucket_key
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  s3_bucket         = data.aws_s3_bucket_object.s3bucket.bucket
  s3_key            = data.aws_s3_bucket_object.s3bucket.key
  s3_object_version = data.aws_s3_bucket_object.s3bucket.version_id
  function_name     = var.function_name
  role              = aws_iam_role.iam_for_lambda.arn
  handler           = var.handler
  source_code_hash  = data.aws_s3_bucket_object.s3bucket.body
  runtime           = var.runtime
  timeout           = var.timeout
  layers            = [var.layers]
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
  ]
  vpc_config {
    subnet_ids         = var.vpc_function ? var.subnets : []
    security_group_ids = var.vpc_function ? var.security_groups : []
  }
  reserved_concurrent_executions = var.cuncurrent_executions
  environment {
    variables = {
      env         = "prod"
      region      = var.region
      bucket      = var.bucket
      domain      = var.domain
      table_name  = var.table_name
      DB_HOST     = var.DB_HOST
      DB_USERNAME = var.DB_USERNAME
      DB_PASSWORD = var.DB_PASSWORD
    }
  }
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 0
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.function_name}-lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  count      = length(var.iam_policy_arn)
  policy_arn = var.iam_policy_arn[count.index]
}

resource "aws_lambda_event_source_mapping" "example" {
  count            = var.sqs_queue ? 1 : 0
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.lambda.arn
  enabled          = true
  batch_size       = 10
}
