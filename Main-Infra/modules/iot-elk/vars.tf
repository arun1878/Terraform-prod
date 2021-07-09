variable "role_name" {}
variable "policy_name" {}
variable "enabled" {
    default = true
}
variable "name" {}
variable "sql" {}
variable "sql_version" {
   default = "2015-10-08"
}

variable "endpoint" {}
variable "index_name" {}
variable "elk_arn" {}