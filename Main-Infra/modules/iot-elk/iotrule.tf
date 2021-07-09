resource "aws_iot_topic_rule" "rule" {
    name        = var.name
    enabled     = var.enabled
    sql         = var.sql
    sql_version = var.sql_version
    elasticsearch {
    endpoint = var.endpoint
    role_arn  =  aws_iam_role.role.arn
    id = "$${newuuid()}"
    index = var.index_name
    type = "_doc"
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
        "Action": "es:ESHttpPut",
        "Resource": "${var.elk_arn}"
    }
  ]
}
EOF
}