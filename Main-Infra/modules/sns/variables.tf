variable "create_sns_topic" {
description = "Need to create sns and subscription or not"
type = bool
default = true
}
variable "name" {
description = "Need to pass a list of topic names"
type = list(string)
}
variable "display_name" {
description = "To use this topic with SMS subscriptions, enter a display name. Only the first 10 characters are displayed in an SMS message."
type = string
}

variable "protocol" {
description = "Type of Protocol to use for SNS"
type = string
default = "email"
}

variable "endpoint" {
description = "need to pass the endpoints for the protocol mentioned"
type = list(map(string))
# default = [{ endpoint_name = "test10@gmail.com", topic_name = "test10" },
# { endpoint_name = "test50@gmail.com", topic_name = "test10" },
# { endpoint_name = "test30@gmail.com", topic_name = "test30" },
# { endpoint_name = "test40@gmail.com", topic_name = "test30" },
# { endpoint_name = "test60@gmail.com", topic_name = "test20" },]
}