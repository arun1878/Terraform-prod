variable "orchestration" {
  default = "code-deploy"
  description = "Link to the orchestration used to create the resources. Used when tagging resources."
}

variable "environment" {
  description = "Environment where resources will be deployed. UAT, DEV, PRD, etc."
}

variable "compute_platform" {
  description = "Compute platform type. ECS, Lambda, or Server."
  default     = "Server"
}

variable "name" {
  description = "CodeDeploy application name."
}

variable "lifecycle_rule_enabled" {
  description = "Enable / disable default lifecycle rule on s3 bucket."
  default     = "true"
}


