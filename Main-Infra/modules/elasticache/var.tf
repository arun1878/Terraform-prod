variable "cluster_id" {
  description = "Cluster ID for redis cluster"
}

variable "replication_group_id" {
  description = "Replication group ID for redis"
}

variable "aws_region" {
  description = "Region you want to use"
  default     = "us-west-2"
}

variable "availability_zones" {
  description = "Availability zone you want to use"
  default     = "us-west-2a"
}

variable "port" {
  description = "Port number you want to use"
  default     = 6379
}

variable "engine_version" {
  description = "Redis engine version you want to use"
  default     = "5.0.6"
}
variable "node_type" {
  description = "Node type you want to use"
}
variable "cluster_type" {
  description = "Cluster type you want to use"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes you want"
  default     = 2
}

variable "public_subnets" {}
variable "group_description" {}
variable "azs" {}

variable "security_group_ids" {
  description = "The security_group ids to attach the instance to"
}

variable "parameter_group_name" {
  default = "default.redis5.0.cluster.on"
}
variable "parameter_group_name_node" {
  default = "default.redis5.0"
}

variable "cluster_name" {
  description = "Cluster Name"
  default     = ""
}

variable "node_name" {
  description = "Node Name"
  default     = ""
}

variable "alarm_threshold_cpu" {
  description = "Threshold for cpu alarm in %"
  type        = number
  default     = 80
}

variable "alarm_threshold_memory" {
  description = "Memory in percent"
  type        = number
  default     = 80
}

variable "alarm_threshold_evictions" {
  description = "Threshold for evictions alarm"
  type        = number
  default     = 0
}

variable "alarm_threshold_swap" {
  description = "Threshold for swap alarm"
  type        = number
  default     = 419430400 # 40MB, 80% of recommended 50MB limit
}

variable "alarm_sns_topic" {
  description = "SNS Topic used for alarms" 
}

variable "node_zones" {}