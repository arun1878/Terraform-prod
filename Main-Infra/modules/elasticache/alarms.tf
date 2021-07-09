# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_cpu" {
#   count               = var.num_cache_nodes
#   alarm_name          = "elasticache-alarm-cpu-${var.cluster_id}-000${count.index + 1}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ElastiCache"
#   period              = 60
#   threshold           = var.alarm_threshold_cpu
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_memory" {
#   count               = var.num_cache_nodes
#   alarm_name          = "elasticache-alarm-memory-${var.cluster_id}-000${count.index + 1}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "DatabaseMemoryUsagePercentage"
#   namespace           = "AWS/ElastiCache"
#   period              = 60
#   threshold           = var.alarm_threshold_memory
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_evictions" {
#   alarm_name          = "elasticache-alarm-evictions-${var.cluster_id}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "Evictions"
#   namespace           = "AWS/ElastiCache"
#   period              = 960
#   threshold           = var.alarm_threshold_evictions
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_swap" {
#   alarm_name          = "elasticache-alarm-swap-${var.cluster_id}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "SwapUsage"
#   namespace           = "AWS/ElastiCache"
#   period              = 300
#   threshold           = var.alarm_threshold_swap
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis.id
#     }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_cpu_1" {
#   count               = var.num_cache_nodes
#   alarm_name          = "elasticache-alarm-cpu-${var.replication_group_id}-000${count.index + 1}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ElastiCache"
#   period              = 60
#   threshold           = var.alarm_threshold_cpu
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis-node.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_memory_1" {
#   count               = var.num_cache_nodes
#   alarm_name          = "elasticache-alarm-memory-${var.replication_group_id}-000${count.index + 1}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "DatabaseMemoryUsagePercentage"
#   namespace           = "AWS/ElastiCache"
#   period              = 60
#   threshold           = var.alarm_threshold_memory
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis-node.id
    
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_evictions_1" {
#   alarm_name          = "elasticache-alarm-evictions-${var.replication_group_id}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "Evictions"
#   namespace           = "AWS/ElastiCache"
#   period              = 960
#   threshold           = var.alarm_threshold_evictions
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis-node.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "elasticache_alarm_swap_1" {
#   alarm_name          = "elasticache-alarm-swap-${var.replication_group_id}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "SwapUsage"
#   namespace           = "AWS/ElastiCache"
#   period              = 300
#   threshold           = var.alarm_threshold_swap
#   statistic           = "Average"
#   alarm_actions = var.alarm_sns_topic
#   ok_actions = var.alarm_sns_topic
#   dimensions = {
#     CacheClusterId = aws_elasticache_replication_group.redis-node.id
#     }
# }