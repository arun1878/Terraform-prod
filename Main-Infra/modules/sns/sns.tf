resource "aws_sns_topic" "alert" {
  count        = var.create_sns_topic && length(var.name) > 0 ? length(var.name) : 0
  name         = var.name[count.index]
  display_name = var.display_name
}

resource "aws_sns_topic_subscription" "alert" {
  count     = var.create_sns_topic && length(var.endpoint) > 0 ? length(var.endpoint) : 0
  topic_arn = aws_sns_topic.alert[index(var.name, var.endpoint[count.index].topic_name)].arn
  protocol  = var.protocol
  endpoint  = var.endpoint[count.index].endpoint_name
}
