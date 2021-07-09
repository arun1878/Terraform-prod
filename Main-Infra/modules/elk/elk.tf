resource "aws_elasticsearch_domain" "default" {
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    internal_user_database_enabled = var.advanced_security_options_internal_user_database_enabled
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }

  domain_endpoint_options {
    enforce_https                   = var.domain_endpoint_options_enforce_https
    tls_security_policy             = var.domain_endpoint_options_tls_security_policy
    custom_endpoint_enabled         = var.custom_endpoint_enabled
    custom_endpoint                 = var.custom_endpoint
    custom_endpoint_certificate_arn = var.custom_endpoint_certificate_arn
  }

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    zone_awareness_enabled   = var.zone_awareness_enabled
    warm_enabled             = var.warm_enabled

    dynamic "zone_awareness_config" {
      for_each = var.availability_zone_count > 1 ? [true] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  log_publishing_options {
    enabled                  = var.log_publishing_index_enabled
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_index_slow.arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_search_enabled
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_search_slow.arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_audit_enabled
    log_type                 = "AUDIT_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_audit.arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_application_enabled
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_application.arn
  }

  tags = {
  Environment = "Production" }
}


resource "aws_cloudwatch_log_group" "es_search_slow" {
  name = "/aws/elasticsearch/search_slow_logs"
  tags = {
    Environment = "production"
    Application = "Elasticsearch"
  }
}

resource "aws_cloudwatch_log_group" "es_index_slow" {
  name = "/aws/elasticsearch/index_slow_logs"
  tags = {
    Environment = "production"
    Application = "Elasticsearch"
  }
}

resource "aws_cloudwatch_log_group" "es_audit" {
  name = "/aws/elasticsearch/audit_logs"
  tags = {
    Environment = "production"
    Application = "Elasticsearch"
  }
}

resource "aws_cloudwatch_log_group" "es_application" {
  name = "/aws/elasticsearch/application_logs"
  tags = {
    Environment = "production"
    Application = "Elasticsearch"
  }
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name     = aws_elasticsearch_domain.default.domain_name
  access_policies = <<POLICIES
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": ["es:*"],
        "Condition": {
          "IpAddress": {"aws:SourceIp": ["0.0.0.0/0"]}
        },
        "Resource": "${aws_elasticsearch_domain.default.arn}/*"
      }
    ]
  }
POLICIES
}
