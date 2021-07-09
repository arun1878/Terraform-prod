variable "function_name" {}
variable "runtime" {}
variable "bucket_name" {}
variable "s3_bucket_key" {}
variable "timeout" {
  default = "3"
}
variable "region" {
  default = null
}
variable "bucket" {
  default = null
}
variable "domain" {
  default = null
}
variable "table_name" {
  default = null
}

variable "DB_HOST" {
  default = null
}

variable "DB_USERNAME" {
  default = null
}

variable "DB_PASSWORD" {
  default = null
}
variable "cuncurrent_executions" {
  default = -1
}

variable "sqs_arn" {}

variable "iam_policy_arn" {
  description = "IAM Policy to be attached to role"
  type        = list(any)
}

variable "sqs_queue" {
  description = "Need to attach sqs queue or not"
  type        = bool
  default     = false
}

variable "handler" {}
variable "layers" {
  default = ""
}

variable "subnets" { default = null }
variable "security_groups" { default = null }

variable "vpc_function" {
  type    = bool
  default = false
}
