variable "name" {}
variable "public_subnets" {
  type        = list(any)
  default     = []
  description = "A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value will for load balancers of type network will force a recreation of the resource."
  sensitive   = true
}
variable "alb_sg_id" {}
variable "vpc_id" {}
variable "aws_instance" {}

variable "content_type" {
  description = "The content type. Valid values are text/plain, text/css, text/html, application/javascript and application/json"
  type        = string
  default     = "text/plain"
}

variable "message_body" {
  description = "The message body."
  type        = string
  default     = "404 Not Found"
}

variable "status_code" {
  description = "The HTTP response code. Valid values are 2XX, 4XX, or 5XX"
  type        = string
  default     = "404"
}

variable "cert_arn" {}