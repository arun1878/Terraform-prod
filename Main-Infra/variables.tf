#VPC
variable "frankfurt_vpc_name" {
  default = "prod-main-vpc"
}
variable "frankfurt_cidr" {
  default= "10.0.0.0/16"
}
variable "frankfurt_azs" {
 default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] 
}
variable "frankfurt_private_subnets" {
  default = ["10.0.16.0/20", "10.0.48.0/20", "10.0.80.0/20"]
}
variable "frankfurt_public_subnets" {
  default = ["10.0.0.0/20", "10.0.32.0/20", "10.0.64.0/20"]
}
variable "key_name" {
  default = "purmo"
}
variable "ip_range" {
  default = "0.0.0.0/0" 
}

#SNS
variable "frankfurt_sns_name" {
  default= ["Devops-Team"]
}
variable "frankfurt_sns_display_name" {
  default = "SNS TOPIC"
}
variable "frankfurt_sns_endpoints" {
  default= [{ endpoint_name = "arun.n@ctiotsolution.com", topic_name = "Devops-Team" }, { endpoint_name = "yashwant.bokadia@ctiotsolution.com", topic_name = "Devops-Team" }, { endpoint_name = "nikhil.s@ctiotsolution.com", topic_name = "Devops-Team" }]
}

# RDS
variable "replica_count" {
  default = "1"
}
variable "monitoring_interval" {
  default ="10"
}
variable "db_parameter_group_name" {
  default = "default.aurora-postgresql11"
}
variable "db_cluster_parameter_group_name" {
  default= "default.aurora-postgresql11"
}
variable "rds_instance_type" {
  default = "db.t3.medium"
}
variable "rds_env" {
  default = "Production"
}
variable "rds_name" {
  default= "prod-purmo"
}
variable "engine" {
  default= "aurora-postgresql"
}
variable "engine_version" {
  default= "11.9"
}
variable "master_username" {
  default = "h2o"
}
variable "master_password" {
  default = "h2o12345"
}

#Elasticache
variable "cluster_name" {
  default = "prod-purmo-cluster"
}
variable "node_name" {
  default = "prod-purmo-redis"
}
variable "redis_azs" {
  default = ["eu-central-1a", "eu-central-1b"]
}
variable "group_description" {
  default = "prod-group"
}
variable "cluster_id" {
  default = "prod-purmo-cluster"
}
variable "replication_group_id" {
  default = "prod-purmo-redis"
}
variable "node_type" {
  default = "cache.t2.small"
}
variable "cluster_type" {
  default = "cache.t2.micro"
}

#EC2
variable "EC2_instance_type" {
  default = "m3.medium"
}
variable "vol_size" {
  default = "80"
}
variable "vol_type" {
  default = "gp2"
}
variable "name" {
  default =""
}
variable "ec2_name" {
  default = "ec2_name"
}

#Lanuch Configuration
variable "instance_type" {
  default = "t2.medium"
}
variable "asg_min" {
  default = "1"
}
variable "asg_max" {
  default = "3"
}
variable "asg_desired" {
  default = "1"
}
variable "amis" {
  default = "ami-04930c07cae183dcf"
}
variable "service_amis" {
  default = "ami-0338139df0b6d5208"
}
variable "base_amis" {
  default = "ami-0d097b81f8d412838"
}
variable "iam_instance_profile" {
  default = "arn:aws:iam::578710726879:instance-profile/prod-devops-role"
}
#ALB
variable "cert_arn" {
  default= "arn:aws:acm:eu-central-1:578710726879:certificate/0d4b50df-049a-4f55-9436-b9b2493656b3" 
}


#ELK
variable "domain_name" {
  default = "test"
}
variable "elk_instance_type" {
  default = "m5.large.elasticsearch"
}

variable "ebs_volume_size" {
  default = 40
}

variable "custom_endpoint" {
  default = "kibana1.purmo.uleeco.com"
}

variable "kibana_cert_arn" {
  default= "arn:aws:acm:eu-central-1:578710726879:certificate/6f37849e-ac22-40bd-9da7-6a66fc229d52"
}

variable "master_user_name" {
  default = "testing"
}

variable "master_user_password" {
  default = "Test@123"
}

#IOT rule
variable "index_name" {
  default = "prod-purmo-aws-thing-$${parse_time(\"yyyy.MM.dd\", timestamp(), \"UTC\")}"
}


#Lambda
variable "bucket_name" {
  default = "prod-purmo-frankfurt-devops-builds"
}

#cloudfront
variable "cloudfront_bucket_name"{
  description = "Name of S3 bucket that will be storing the content for CDN"
  default = "purmo-prod-images"
}

variable "cache_policy_id" {
  description = "Id of Cloudfront cache policy - 'Managed-CachingOptimized'"
  default= "658327ea-f89d-4fab-a63d-7e88639e58f6"
}