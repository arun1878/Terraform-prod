resource "aws_sqs_queue" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  name_prefix = var.name_prefix

  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  #policy                      = data.aws_iam_policy_document.sqs_policy.json
  policy                      = ""
  redrive_policy              = var.redrive_policy
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  tags = var.tags
}


resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.this[0].id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.this[0].arn}"
    }
  ]
}
POLICY
}