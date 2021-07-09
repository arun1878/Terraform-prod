resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
  depends_on = [aws_iam_role_policy.firehose_role]
  name        = var.name
  destination = "elasticsearch"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
  }

  elasticsearch_configuration {
    domain_arn = var.elk_domain_arn
    role_arn   = aws_iam_role.firehose_role.arn
    index_name = "test"
    buffering_interval = 60
    buffering_size = 1 
    index_rotation_period = "OneDay"
    retry_duration = 300
    s3_backup_mode = "FailedDocumentsOnly"
    cloudwatch_logging_options {
      enabled = true
      log_group_name = "/aws/kinesisfirehose/${var.name}"
      log_stream_name = "/aws/kinesisfirehose/${var.name}"
    }
  }
}


resource "aws_s3_bucket" "bucket" {
  bucket = var.kinesis_bucket_name
  acl    = "private"
}


resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "firehose_role" {
  role = "${aws_iam_role.firehose_role.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["${aws_s3_bucket.bucket.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": ["es:*"],
      "Resource": ["${var.elk_domain_arn}", "${var.elk_domain_arn}/*"]
    },
    {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:DeleteNetworkInterface"
          ],
          "Resource": [
            "*"
          ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:logs:*:*:log-group:*:log-stream:*"
      ]
    }
  ]
}
EOF
}

