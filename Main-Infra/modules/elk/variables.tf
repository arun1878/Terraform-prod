variable "domain_name" {}

variable "elasticsearch_version" {
  type    = string
  default = "7.10"
}

variable "instance_type" {
  type        = string
  default     = "t3.small.elasticsearch"
  description = "Elasticsearch instance type for data nodes in the cluster"
}

variable "instance_count" {
  type        = number
  description = "Number of data nodes in the cluster"
  default     = 3
}

variable "warm_enabled" {
  type        = bool
  default     = false
  description = "Whether AWS UltraWarm is enabled"
}

variable "zone_awareness_enabled" {
  type        = bool
  default     = true
  description = "Enable zone awareness for Elasticsearch cluster"
}

variable "availability_zone_count" {
  type        = number
  default     = 3
  description = "Number of Availability Zones for the domain to use."
}

variable "ebs_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable ebs or not"
}

variable "ebs_volume_size" {
  type        = number
  description = "EBS volumes for data storage in GB"
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "Storage type of EBS volumes"
}

variable "encrypt_at_rest_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable encryption at rest"
}

variable "domain_endpoint_options_enforce_https" {
  type        = bool
  default     = true
  description = "Whether or not to require HTTPS"
}

variable "domain_endpoint_options_tls_security_policy" {
  type        = string
  default     = "Policy-Min-TLS-1-0-2019-07"
  description = "The name of the TLS security policy that needs to be applied to the HTTPS endpoint"
}


variable "log_publishing_index_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for INDEX_SLOW_LOGS is enabled or not"
}

variable "log_publishing_search_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for SEARCH_SLOW_LOGS is enabled or not"
}

variable "log_publishing_audit_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for AUDIT_LOGS is enabled or not"
}

variable "log_publishing_application_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether log publishing option for ES_APPLICATION_LOGS is enabled or not"
}

variable "automated_snapshot_start_hour" {
  type        = number
  description = "Hour at which automated snapshots are taken, in UTC"
  default     = 0
}

variable "dedicated_master_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
}

variable "dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes in the cluster"
  default     = 0
}

variable "dedicated_master_type" {
  type        = string
  default     = "t2.small.elasticsearch"
  description = "Instance type of the dedicated master nodes in the cluster"
}

variable "node_to_node_encryption_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable node-to-node encryption"
}

variable "domain_hostname_enabled" {
  type        = bool
  description = "Explicit flag to enable creating a DNS hostname for ES. If `true`, then `var.dns_zone_id` is required."
  default     = false
}

variable "kibana_hostname_enabled" {
  type        = bool
  description = "Explicit flag to enable creating a DNS hostname for Kibana. If `true`, then `var.dns_zone_id` is required."
  default     = false
}

variable "advanced_security_options_enabled" {
  type        = bool
  default     = true
  description = "AWS Elasticsearch Kibana enchanced security plugin enabling (forces new resource)"
}

variable "advanced_security_options_internal_user_database_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable or not internal Kibana user database for ELK OpenDistro security plugin"
}

variable "master_user_name" {
  type        = string
  description = "Master user username (applicable if advanced_security_options_internal_user_database_enabled set to true)"
}

variable "master_user_password" {
  type        = string
  description = "Master user password (applicable if advanced_security_options_internal_user_database_enabled set to true)"
}

variable "custom_endpoint_enabled" {
  type        = bool
  description = "Whether to enable custom endpoint for the Elasticsearch domain."
  default     = true
}

variable "custom_endpoint" {
  type        = string
  description = "Fully qualified domain for custom endpoint."
}

variable "custom_endpoint_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for custom endpoint."
}
