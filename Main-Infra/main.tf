terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44.0"
    }
  }
  required_version = ">= 0.14.9"

  backend "s3" {
    bucket         = "ctiot-terraform-state"
    key            = "purmo-prod/main-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  alias   = "tfstate"
  profile = "ctiotsolutiondev"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "ctiotsolutiondev_main"
  profile = "ctiotsolutiondev"
  region  = "us-east-1"
}

provider "aws" {
  profile = "purmo-prod"
  region  = "eu-central-1"
}

#VPC Creation
module "vpc-Frankfurt" {
  source = "./modules/vpc"
  providers = {
    aws = aws
  }
  key_name             = var.key_name
  ip_range             = var.ip_range
  name                 = var.frankfurt_vpc_name
  cidr                 = var.frankfurt_cidr
  azs                  = var.frankfurt_azs
  private_subnets      = var.frankfurt_private_subnets
  public_subnets       = var.frankfurt_public_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  create_igw           = true
}

#SNS topic creation
module "sns-Frankfurt" {
  source = "./modules/sns"
  providers = {
    aws = aws
  }
  name         = var.frankfurt_sns_name
  display_name = var.frankfurt_sns_display_name
  endpoint     = var.frankfurt_sns_endpoints
}

#RDS & related alarms creation - PostgreSQL aurora
module "rds-Frankfurt" {
  source = "./modules/rds"
  providers = {
    aws = aws
  }
  name                            = var.rds_name
  engine                          = var.engine
  username                        = var.master_username
  password                        = var.master_password
  engine_version                  = var.engine_version
  instance_type                   = var.rds_instance_type
  vpc_id                          = module.vpc-Frankfurt.vpc_id
  subnets                         = module.vpc-Frankfurt.public_subnets
  replica_count                   = var.replica_count
  allowed_security_groups         = ["${module.vpc-Frankfurt.ssh_sg_id}", "${module.vpc-Frankfurt.postgres_sg_id}"]
  allowed_cidr_blocks             = ["${module.vpc-Frankfurt.vpc_cidr_block}"]
  storage_encrypted               = true
  apply_immediately               = true
  monitoring_interval             = var.monitoring_interval
  db_parameter_group_name         = var.db_parameter_group_name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  enabled_cloudwatch_logs_exports = ["postgresql"]
  sns_topic_arn                   = module.sns-Frankfurt.sns_topic_arn
  tags = {
    Environment = var.rds_env
  }
}

module "elasticache-Frankfurt" {
  source               = "./modules/elasticache"
  cluster_name         = var.cluster_name
  node_name            = var.node_name
  node_type            = var.node_type
  cluster_type         = var.cluster_type
  azs                  = var.redis_azs
  node_zones           = var.redis_azs
  group_description    = var.group_description
  cluster_id           = var.cluster_id
  replication_group_id = var.replication_group_id
  security_group_ids   = ["${module.vpc-Frankfurt.ssh_sg_id}", "${module.vpc-Frankfurt.redis_sg_id}"]
  public_subnets       = module.vpc-Frankfurt.public_subnets
  alarm_sns_topic      = module.sns-Frankfurt.sns_topic_arn
}

module "grafana" {
  source             = "./modules/ec2"
  amis               = var.base_amis
  name               = "/prod-purmo/grafana"
  instance_type      = var.EC2_instance_type
  availability_zones = var.frankfurt_azs
  key_name           = var.key_name
  vol_size           = var.vol_size
  vol_type           = var.vol_type
  security_group_ids = ["${module.vpc-Frankfurt.ssh_sg_id}", "${module.vpc-Frankfurt.grafana_sg_id}", "${module.vpc-Frankfurt.node_sg_id}"]
  public_subnets     = ["${module.vpc-Frankfurt.public_subnets[0]}"]
}

module "grafana_lb" {
  source       = "./modules/grafana_lb"
  listener_arn = module.alb-Frankfurt.alb_listener
  priority     = 600
  host_header  = "monitor.purmo.uleeco.com"
  vpc_id       = module.vpc-Frankfurt.vpc_id
  alb_name     = module.alb-Frankfurt.alb_name
  aws_instance = module.grafana.aws_instance
}

module "DevOps" {
  source             = "./modules/ec2"
  amis               = var.base_amis
  name               = "/prod-purmo/devops"
  instance_type      = var.EC2_instance_type
  availability_zones = var.frankfurt_azs
  key_name           = var.key_name
  vol_size           = var.vol_size
  vol_type           = var.vol_type
  security_group_ids = ["${module.vpc-Frankfurt.ssh_sg_id}", "${module.vpc-Frankfurt.elasticsearch_sg_id}", "${module.vpc-Frankfurt.node_sg_id}"]
  public_subnets     = ["${module.vpc-Frankfurt.public_subnets[0]}"]
}

module "alb-Frankfurt" {
  source         = "./modules/alb"
  name           = "external-alb"
  cert_arn       = var.cert_arn
  public_subnets = ["${module.vpc-Frankfurt.public_subnets}"]
  alb_sg_id      = module.vpc-Frankfurt.alb_sg_id
  vpc_id         = module.vpc-Frankfurt.vpc_id
  aws_instance   = module.grafana.aws_instance
}

module "Service_lc" {
  source               = "./modules/launch_config"
  service_name         = "prod-purmo-service-api"
  https_inbound_sg_id  = module.vpc-Frankfurt.https_inbound_sg_id
  grafana_sg_id        = module.vpc-Frankfurt.grafana_sg_id
  public_subnets       = ["${module.vpc-Frankfurt.public_subnets}"]
  ssh_sg_id            = module.vpc-Frankfurt.ssh_sg_id
  private_subnets      = ["${module.vpc-Frankfurt.private_subnets}"]
  node_sg_id           = module.vpc-Frankfurt.node_sg_id
  key_name             = var.key_name
  amis                 = var.service_amis
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  SERVICE              = "service-api"
}
module "Service_lb" {
  source              = "./modules/lb"
  service_name        = "prod-purmo-service-api"
  https_inbound_sg_id = module.vpc-Frankfurt.https_inbound_sg_id
  vpc_id              = module.vpc-Frankfurt.vpc_id
  asg_id              = module.Service_asg.asg_id
  alb_name            = module.alb-Frankfurt.alb_name
  listener_arn        = module.alb-Frankfurt.alb_listener
  priority            = 100
  target_port         = "3000"
  host_header         = "service-api.purmo.uleeco.com"
}
module "Service_asg" {
  service_name         = "prod-purmo-service-api"
  source               = "./modules/asg"
  tag_name             = "/prod-purmo/service-api"
  public_subnets       = module.vpc-Frankfurt.public_subnets
  launch_config_id     = module.Service_lc.launch_config_id
  launch_config_name   = module.Service_lc.launch_config_name
  elb_target_group_arn = module.Service_lb.elb_target_group_arn
  asg_min              = var.asg_min
  asg_max              = var.asg_max
}

module "Console_lc" {
  source               = "./modules/launch_config"
  service_name         = "prod-purmo-console-ui"
  https_inbound_sg_id  = module.vpc-Frankfurt.https_inbound_sg_id
  public_subnets       = ["${module.vpc-Frankfurt.public_subnets}"]
  ssh_sg_id            = module.vpc-Frankfurt.ssh_sg_id
  private_subnets      = ["${module.vpc-Frankfurt.private_subnets}"]
  node_sg_id           = module.vpc-Frankfurt.node_sg_id
  key_name             = var.key_name
  amis                 = var.amis
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  SERVICE              = "console-ui"
}
module "Console_lb" {
  service_name        = "prod-purmo-console-ui"
  source              = "./modules/lb"
  https_inbound_sg_id = module.vpc-Frankfurt.https_inbound_sg_id
  vpc_id              = module.vpc-Frankfurt.vpc_id
  asg_id              = module.Console_asg.asg_id
  alb_name            = module.alb-Frankfurt.alb_name
  listener_arn        = module.alb-Frankfurt.alb_listener
  priority            = 200
  target_port         = "3000"
  host_header         = "app.purmo.uleeco.com"
}
module "Console_asg" {
  service_name         = "prod-purmo-console-ui"
  source               = "./modules/asg"
  tag_name             = "/prod-purmo/console-ui"
  public_subnets       = module.vpc-Frankfurt.public_subnets
  launch_config_id     = module.Console_lc.launch_config_id
  launch_config_name   = module.Console_lc.launch_config_name
  elb_target_group_arn = module.Console_lb.elb_target_group_arn
  asg_min              = var.asg_min
  asg_max              = var.asg_max
}

module "RuleEngine_lc" {
  source               = "./modules/launch_config"
  service_name         = "prod-purmo-rule-engine-sqs"
  https_inbound_sg_id  = module.vpc-Frankfurt.https_inbound_sg_id
  public_subnets       = ["${module.vpc-Frankfurt.public_subnets}"]
  ssh_sg_id            = module.vpc-Frankfurt.ssh_sg_id
  private_subnets      = ["${module.vpc-Frankfurt.private_subnets}"]
  node_sg_id           = module.vpc-Frankfurt.node_sg_id
  key_name             = var.key_name
  amis                 = var.amis
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  SERVICE              = "rule-engine-sqs"
}
module "RuleEngine_lb" {
  service_name        = "prod-purmo-rule-engine-sqs"
  source              = "./modules/lb"
  https_inbound_sg_id = module.vpc-Frankfurt.https_inbound_sg_id
  vpc_id              = module.vpc-Frankfurt.vpc_id
  asg_id              = module.RuleEngine_asg.asg_id
  alb_name            = module.alb-Frankfurt.alb_name
  listener_arn        = module.alb-Frankfurt.alb_listener
  priority            = 300
  target_port         = "3000"
  host_header         = "rule-engine.purmo.uleeco.com"
}
module "RuleEngine_asg" {
  service_name         = "prod-purmo-rule-engine-sqs"
  source               = "./modules/asg"
  tag_name             = "/prod-purmo/rule-engine-sqs"
  public_subnets       = module.vpc-Frankfurt.public_subnets
  launch_config_id     = module.RuleEngine_lc.launch_config_id
  launch_config_name   = module.RuleEngine_lc.launch_config_name
  elb_target_group_arn = module.RuleEngine_lb.elb_target_group_arn
  asg_min              = var.asg_min
  asg_max              = var.asg_max
}

module "Device_Updater_lc" {
  source               = "./modules/launch_config"
  service_name         = "prod-purmo-device-updater"
  https_inbound_sg_id  = module.vpc-Frankfurt.https_inbound_sg_id
  public_subnets       = ["${module.vpc-Frankfurt.public_subnets}"]
  ssh_sg_id            = module.vpc-Frankfurt.ssh_sg_id
  private_subnets      = ["${module.vpc-Frankfurt.private_subnets}"]
  node_sg_id           = module.vpc-Frankfurt.node_sg_id
  key_name             = var.key_name
  amis                 = var.amis
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  SERVICE              = "device-status-updater"
}
module "Device_Updater_lb" {
  service_name        = "prod-purmo-device-updater"
  source              = "./modules/lb"
  https_inbound_sg_id = module.vpc-Frankfurt.https_inbound_sg_id
  vpc_id              = module.vpc-Frankfurt.vpc_id
  asg_id              = module.Device_Updater_asg.asg_id
  alb_name            = module.alb-Frankfurt.alb_name
  listener_arn        = module.alb-Frankfurt.alb_listener
  priority            = 400
  target_port         = "3000"
  host_header         = "device-updater.purmo.uleeco.com"
}
module "Device_Updater_asg" {
  service_name         = "prod-purmo-device-updater"
  source               = "./modules/asg"
  tag_name             = "/prod-purmo/device-updater"
  public_subnets       = module.vpc-Frankfurt.public_subnets
  launch_config_id     = module.Device_Updater_lc.launch_config_id
  launch_config_name   = module.Device_Updater_lc.launch_config_name
  elb_target_group_arn = module.Device_Updater_lb.elb_target_group_arn
  asg_min              = var.asg_min
  asg_max              = var.asg_max
}

module "Cube_lc" {
  source               = "./modules/launch_config"
  service_name         = "prod-purmo-cube-server"
  https_inbound_sg_id  = module.vpc-Frankfurt.https_inbound_sg_id
  public_subnets       = ["${module.vpc-Frankfurt.public_subnets}"]
  ssh_sg_id            = module.vpc-Frankfurt.ssh_sg_id
  private_subnets      = ["${module.vpc-Frankfurt.private_subnets}"]
  node_sg_id           = module.vpc-Frankfurt.node_sg_id
  key_name             = var.key_name
  amis                 = var.amis
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  SERVICE              = "cube-server"
}
module "Cube_lb" {
  service_name        = "prod-purmo-cube-server"
  source              = "./modules/lb"
  https_inbound_sg_id = module.vpc-Frankfurt.https_inbound_sg_id
  vpc_id              = module.vpc-Frankfurt.vpc_id
  asg_id              = module.Cube_asg.asg_id
  alb_name            = module.alb-Frankfurt.alb_name
  listener_arn        = module.alb-Frankfurt.alb_listener
  priority            = 500
  target_port         = "4000"
  host_header         = "cube.purmo.uleeco.com"
}
module "Cube_asg" {
  service_name         = "prod-purmo-cube-server"
  source               = "./modules/asg"
  tag_name             = "/prod-purmo/cube-server"
  public_subnets       = module.vpc-Frankfurt.public_subnets
  launch_config_id     = module.Cube_lc.launch_config_id
  launch_config_name   = module.Cube_lc.launch_config_name
  elb_target_group_arn = module.Cube_lb.elb_target_group_arn
  asg_min              = var.asg_min
  asg_max              = var.asg_max
}

module "codedeploy" {
  source           = "./modules/codedeploy"
  environment      = "prod"
  compute_platform = "Server"
  name             = "purmo"
}

module "codedeploy_Service" {
  source                   = "./modules/deployment_groups"
  environment              = "prod"
  codedeploy_app           = module.codedeploy.codedeploy_app
  codedeploy_service_role  = module.codedeploy.codedeploy_service_role
  autoscaling_groups       = module.Service_asg.asg_id
  service_name             = "service-api"
  traffic_control          = "WITH_TRAFFIC_CONTROL"
  aws_lb_target_group_name = module.Service_lb.elb_target_group_name
  aws_lb_target_group      = module.Service_lb.elb_target_group_arn
}

module "codedeploy_console_UI" {
  source                   = "./modules/deployment_groups"
  environment              = "prod"
  codedeploy_app           = module.codedeploy.codedeploy_app
  codedeploy_service_role  = module.codedeploy.codedeploy_service_role
  autoscaling_groups       = module.Console_asg.asg_id
  service_name             = "console-ui"
  traffic_control          = "WITH_TRAFFIC_CONTROL"
  aws_lb_target_group_name = module.Console_lb.elb_target_group_name
  aws_lb_target_group      = module.Console_lb.elb_target_group_arn
}

module "codedeploy_ruleengine" {
  source                   = "./modules/deployment_groups"
  environment              = "prod"
  codedeploy_app           = module.codedeploy.codedeploy_app
  codedeploy_service_role  = module.codedeploy.codedeploy_service_role
  autoscaling_groups       = module.RuleEngine_asg.asg_id
  service_name             = "ruleEngine"
  aws_lb_target_group_name = module.RuleEngine_lb.elb_target_group_name
  aws_lb_target_group      = module.RuleEngine_lb.elb_target_group_arn
}

module "codedeploy_Device_Updater" {
  source                   = "./modules/deployment_groups"
  environment              = "prod"
  codedeploy_app           = module.codedeploy.codedeploy_app
  codedeploy_service_role  = module.codedeploy.codedeploy_service_role
  autoscaling_groups       = module.Device_Updater_asg.asg_id
  service_name             = "device-updater"
  aws_lb_target_group_name = module.Device_Updater_lb.elb_target_group_name
  aws_lb_target_group      = module.Device_Updater_lb.elb_target_group_arn
}

module "codedeploy_Cube" {
  source                   = "./modules/deployment_groups"
  environment              = "prod"
  codedeploy_app           = module.codedeploy.codedeploy_app
  codedeploy_service_role  = module.codedeploy.codedeploy_service_role
  autoscaling_groups       = module.Cube_asg.asg_id
  service_name             = "cube"
  traffic_control          = "WITH_TRAFFIC_CONTROL"
  aws_lb_target_group_name = module.Cube_lb.elb_target_group_name
  aws_lb_target_group      = module.Cube_lb.elb_target_group_arn
}

module "dynamodb" {
  source = "./modules/dynamodb"
  #lambda_arn = module.lambdaPurmoDynamoTriggers.lambda_arn
}


module "SqsRuleEngineDelete" {
  source                     = "./modules/sqs"
  name                       = "SqsRuleEngineDelete"
  create                     = true
  visibility_timeout_seconds = 1000
  message_retention_seconds  = 604800
}

module "SqsRuleEngineUpdateDocuments" {
  source                     = "./modules/sqs"
  name                       = "SqsRuleEngineUpdateDocuments"
  create                     = true
  visibility_timeout_seconds = 1000
  message_retention_seconds  = 604800
}

module "SqsForDeviceUpdate" {
  source                     = "./modules/sqs"
  name                       = "SqsForDeviceUpdate"
  create                     = true
  visibility_timeout_seconds = 1000
  message_retention_seconds  = 604800
}

# module "SqsForRuleHandler" {
#   source                     = "./modules/sqs"
#   name                       = "SqsForRuleHandler"
#   create                     = true
#   visibility_timeout_seconds = 1000
#   message_retention_seconds  = 604800
# }

module "SqsForMongoDBUpdateDocuments" {
  source                     = "./modules/sqs"
  name                       = "SqsForMongoDBUpdateDocuments"
  create                     = true
  visibility_timeout_seconds = 1000
  message_retention_seconds  = 604800
}

module "SqsForElasticSearchUpdate" {
  source                     = "./modules/sqs"
  name                       = "SqsForElasticSearchUpdate"
  create                     = true
  visibility_timeout_seconds = 1000
  message_retention_seconds  = 604800
}

module "MongoDBUpdateDocuments" {
  source       = "./modules/iot-sqs"
  name         = "MongoDBUpdateDocuments"
  sqs_queue_id = module.SqsForMongoDBUpdateDocuments.sqs_queue_id
  sqs_id_arn   = module.SqsForMongoDBUpdateDocuments.sqs_queue_arn
  role_name    = "MongoDBUpdateDocuments-role"
  policy_name  = "MongoDBUpdateDocuments-policy"
  sql          = "SELECT *, timestamp() as parsedAt, topic(3) as topic_name FROM '$aws/things/+/shadow/update/documents'"
}

module "IoTSQSElasticSearchUpdate" {
  source       = "./modules/iot-sqs"
  name         = "ElasticSearchUpdateSQS"
  sqs_queue_id = module.SqsForElasticSearchUpdate.sqs_queue_id
  sqs_id_arn   = module.SqsForElasticSearchUpdate.sqs_queue_arn
  role_name    = "ElasticSearchUpdate-sqs-role"
  policy_name  = "ElasticSearchUpdate-sqs-policy"
  sql          = "SELECT *, timestamp() as parsedAt, topic(3) as topic_name FROM '$aws/things/+/shadow/update'"
}

module "IoTRuleEngineDelete" {
  source       = "./modules/iot-sqs"
  name         = "RuleEngineDelete"
  sqs_queue_id = module.SqsRuleEngineDelete.sqs_queue_id
  sqs_id_arn   = module.SqsRuleEngineDelete.sqs_queue_arn
  role_name    = "RuleEngineDelete-role"
  policy_name  = "RuleEngineDelete-policy"
  sql          = "SELECT *, timestamp() as parsedAt, topic(3) as topic_name FROM '$aws/things/+/shadow/delete/accepted'"
}

module "IoTRuleEngineUpdateDocuments" {
  source       = "./modules/iot-sqs"
  name         = "RuleEngineUpdateDocuments"
  sqs_queue_id = module.SqsRuleEngineUpdateDocuments.sqs_queue_id
  sqs_id_arn   = module.SqsRuleEngineUpdateDocuments.sqs_queue_arn
  role_name    = "RuleEngineUpdateDocuments-role"
  policy_name  = "RuleEngineUpdateDocuments-policy"
  sql          = "SELECT *, timestamp() as parsedAt, topic(3) as topic_name FROM '$aws/things/+/shadow/update/documents'"
}

module "service_401metricfiler" {
  source                          = "./modules/metricfilter"
  name                            = "GET-401-User_not_authorized"
  pattern                         = "{ ($.stackTrace= \"User not authorized\") && ($.http_response.status= 401) &&($.request.method=\"GET\")}"
  log_group_name                  = "/service-api/prod/app.log"
  metric_transformation_name      = "GET-401-User_not_authorized"
  metric_transformation_namespace = "purmo-prod-service-api"
}

module "service_404metricfiler" {
  source                          = "./modules/metricfilter"
  name                            = "ApplicationError_DevicesNotFound"
  pattern                         = "{ ($.http_response.status= 404) && ($.request.method=\"GET\") }"
  log_group_name                  = "/service-api/prod/app.log"
  metric_transformation_name      = "ApplicationError_DevicesNotFound"
  metric_transformation_namespace = "purmo-prod-service-api"
}

module "service_Sequelizefiler" {
  source                          = "./modules/metricfilter"
  name                            = "SequelizeValidationError"
  pattern                         = "{$.name=\"SequelizeValidationError\"}"
  log_group_name                  = "/service-api/prod/app.log"
  metric_transformation_name      = "SequelizeValidationError"
  metric_transformation_namespace = "purmo-prod-service-api"
}

module "service_typeError" {
  source                          = "./modules/metricfilter"
  name                            = "TypeError"
  pattern                         = "{($.stack= \"TypeError\")}"
  log_group_name                  = "/service-api/prod/app.log"
  metric_transformation_name      = "TypeError"
  metric_transformation_namespace = "purmo-prod-service-api"
}

module "console_webpack" {
  source                          = "./modules/metricfilter"
  name                            = "webpack.Progress"
  pattern                         = "\"webpack.Progress\""
  log_group_name                  = "/console-ui/prod/npm-error.log"
  metric_transformation_name      = "webpack.Progress"
  metric_transformation_namespace = "purmo-prod-console-ui"
}

module "ELK_DataInsertIssue" {
  source                          = "./modules/metricfilter"
  name                            = "DataInsertIssue"
  pattern                         = "\"Data Insert Issue\""
  log_group_name                  = "/aws/lambda/ElasticsearchUpdate"
  metric_transformation_name      = "DataInsertIssue"
  metric_transformation_namespace = "purmo-prod"
  #unit                            = "Count"
}

module "ELK_DataParsingIssue" {
  source                          = "./modules/metricfilter"
  name                            = "DataParsingIssue"
  pattern                         = "\"Data Parsing Issue\""
  log_group_name                  = "/aws/lambda/ElasticsearchUpdate"
  metric_transformation_name      = "DataParsingIssue"
  metric_transformation_namespace = "purmo-prod"
  #unit                            = "Count"
}

module "ELK_ErrorInCloudwatchUpdateMetric" {
  source                          = "./modules/metricfilter"
  name                            = "ErrorInCloudwatchUpdateMetric"
  pattern                         = "\"ERROR IN CLOUDWATCH UPDATE METRIC\""
  log_group_name                  = "/aws/lambda/ElasticsearchUpdate"
  metric_transformation_name      = "ErrorInCloudwatchUpdateMetric"
  metric_transformation_namespace = "purmo-prod"
  #unit                            = "Count"
}

module "Mongo_DataInsertIssue" {
  source                          = "./modules/metricfilter"
  name                            = "DataInsertIssue"
  pattern                         = "\"Data Insert Issue\""
  log_group_name                  = "/aws/lambda/MongoDBUpdateDocuments"
  metric_transformation_name      = "DataInsertIssue"
  metric_transformation_namespace = "purmo-prod"
  #unit                            = "Count"
}

module "Mongo_DataParsingIssue" {
  source                          = "./modules/metricfilter"
  name                            = "DataParsingIssue"
  pattern                         = "\"Data Parsing Issue\""
  log_group_name                  = "/aws/lambda/MongoDBUpdateDocuments"
  metric_transformation_name      = "DataParsingIssue"
  metric_transformation_namespace = "purmo-prod"
  #unit                            = "Count"
}

module "Mongo_ErrorInCloudwatchUpdateMetric" {
  source                          = "./modules/metricfilter"
  name                            = "ErrorInCloudwatchUpdateMetric"
  pattern                         = "\"ERROR IN CLOUDWATCH UPDATE METRIC\""
  log_group_name                  = "/aws/lambda/MongoDBUpdateDocuments"
  metric_transformation_name      = "ErrorInCloudwatchUpdateMetric"
  metric_transformation_namespace = "purmo-prod"
  #unit                            = "Count"
}

module "ELK" {
  source = "./modules/elk"
  domain_name = var.domain_name
  instance_type = var.elk_instance_type
  ebs_volume_size = var.ebs_volume_size
  custom_endpoint = var.custom_endpoint
  custom_endpoint_certificate_arn = var.kibana_cert_arn
  master_user_name = var.master_user_name
  master_user_password = var.master_user_password
}

module "lambdaPurmoGateway" {
    source = "./modules/Lambda"
    function_name = "PurmoGateway"
    handler    = "index.handler"
    runtime = "nodejs14.x"
    bucket_name = var.bucket_name
    s3_bucket_key    = "Purmo-terraform/Lambda-terraform/Lambda/PurmoGateway.zip"
    iam_policy_arn = [ "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"]
}

module "lambdaPurmoDynamoTriggers" {
    source = "./modules/Lambda"
    function_name = "PurmoDynamoTriggers"
    handler    = "index.handler"
    runtime = "nodejs14.x"
    bucket_name = var.bucket_name
    s3_bucket_key    = "Purmo-terraform/Lambda-terraform/Lambda/PurmoDynamoTriggers.zip"
    iam_policy_arn = [ "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole", "arn:aws:iam::aws:policy/AWSLambdaInvocation-DynamoDB"]
}

module "lambdaSetGatewayImage" {
    source = "./modules/Lambda"
    function_name = "SetGatewayImage"
    runtime = "python3.8"
    handler    = "lambda_function.lambda_handler"
    bucket_name = var.bucket_name
    s3_bucket_key    = "Purmo-terraform/Lambda-terraform/Lambda/SetGatewayImage.zip"
    bucket = var.cloudfront_bucket_name
    domain = "https://${module.cloudfront.domain_name}"
    table_name = "GatewayAttributes"
}

module "lambdaOTP" {
    source = "./modules/Lambda"
    function_name = "OTP"
    handler    = "index.handler"
    runtime = "nodejs14.x"
    bucket_name = var.bucket_name
    s3_bucket_key    = "Purmo-terraform/Lambda-terraform/Lambda/OTP.zip"
    region = "eu-central-1"
    timeout = "30"
}

module "APIOTP" {
    source = "./modules/API"
    OTP_rest_api_name = "OTP"
    Dash_rest_api_name = "GetDashBoardData"
    Gateway_rest_api_name = "SetGatewayImage"
    region = "eu-central-1"
    otp_arn = module.lambdaOTP.lambda_arn
    dashboard_arn = module.lambdaPurmoGateway.lambda_arn
    GatewayImage_arn = module.lambdaSetGatewayImage.lambda_arn
}

module "cloudfront" {
  source = "./modules/cloudfront"
  bucket_name = var.cloudfront_bucket_name
  cache_policy_id= var.cache_policy_id
}


module "LambdaElasticSearchUpdate" {
    source = "./modules/Lambda"
    function_name = "ElasticSearchUpdate"
    runtime = "python3.8"
    bucket_name = var.bucket_name
    handler    = "lambda_function.lambda_handler"
    s3_bucket_key    = "Purmo-terraform/Lambda-terraform/Lambda/ElasticsearchUpdate.zip"
    timeout = "300"
    sqs_queue = true
    sqs_arn = module.SqsForElasticSearchUpdate.sqs_queue_arn
    iam_policy_arn = [ "arn:aws:iam::aws:policy/CloudWatchFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
                       "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

module "LambdaMongoDBUpdate" {
  source                = "./modules/Lambda"
  function_name         = "MongoDBUpdateDocuments"
  runtime               = "python3.8"
  bucket_name           = var.bucket_name
  s3_bucket_key         = "Purmo-terraform/Lambda-terraform/Lambda/MongoDBUpdateDocuments.zip"
  timeout               = "900"
  sqs_queue             = true
  handler               = "lambda_function.lambda_handler"
  vpc_function          = true
  subnets               = module.vpc-Frankfurt.public_subnets
  DB_HOST               = module.CloudFormationMongoDB.primary_ip
  DB_PASSWORD           = "yYJx36b0xhcW"
  DB_USERNAME           = "admin"
  cuncurrent_executions = 5
  security_groups       = ["${module.vpc-Frankfurt.bastion_sg_id}", "${module.vpc-Frankfurt.mongodb_sg_id}"]
  layers                = module.LambdaLayerMongoDBUpdate.layer_arn
  sqs_arn               = module.SqsForMongoDBUpdateDocuments.sqs_queue_arn
  iam_policy_arn = ["arn:aws:iam::aws:policy/CloudWatchFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
}

module "LambdaLayerMongoDBUpdate" {
  source        = "./modules/Lambda-layers"
  runtime       = "python3.8"
  bucket_name   = var.bucket_name
  s3_bucket_key = "Purmo-terraform/Lambda-terraform/Layer/pymongo-package.zip"
  layer_name    = "pymongo-package"
}

module "Kinesis" {
  source = "./modules/kinesis"
  name = "ElasticSearchUpdateSQS"
  elk_domain_arn = module.ELK.domain_arn
  kinesis_bucket_name = "prod-purmo-elasticsearch"
}

module "CloudFormationMongoDB" {
    source = "./modules/cloudformation"
    stackname = "Purmo-Mongo"
    bastion_sg_id = module.vpc.bastion_sg_id
    KeyPairName = "Terra"
    MongoDBAdminPassword = "yYJx36b0xhcW"
    MongoDBAdminUsername = "admin"
    NodeInstanceType = "m3.medium"
    PrimaryNodeSubnet = module.vpc.public_subnets[1]
    Secondary0NodeSubnet = module.vpc.public_subnets[2]
    Secondary1NodeSubnet = module.vpc.public_subnets[2]
    QSS3BucketRegion = "eu-central-1"
    vpc_id = module.vpc.vpc_id
    VolumeSize = "40"
    VolumeType = "gp2"
}