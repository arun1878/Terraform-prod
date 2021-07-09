resource "aws_iot_topic_rule" "rule" {
    name        = var.name
    enabled     = var.enabled
    sql         = var.sql
    sql_version = var.sql_version
    sqs {
    queue_url = var.sqs_queue_id
    role_arn  =  aws_iam_role.role.arn
    use_base64 = false
  } 
}

resource "aws_iam_role" "role" {
  name = var.role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_policy_for_iotrule" {
  name = var.policy_name
  role = aws_iam_role.role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "sqs:SendMessage",
        "Resource": "${var.sqs_id_arn}"
    }
  ]
}
EOF
}