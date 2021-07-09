variable "sqs_queue_id" {}
variable "role_name" {}
variable "policy_name" {}
variable "sqs_id_arn" {}
variable "enabled" {
    default = true
}
variable "name" {}
variable "sql" {}
variable "sql_version" {
   default = "2015-10-08"
}
