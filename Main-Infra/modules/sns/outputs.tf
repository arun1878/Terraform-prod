output "sns_topic_arn" {
description = "ARN of SNS"
value = aws_sns_topic.alert.*.arn
}