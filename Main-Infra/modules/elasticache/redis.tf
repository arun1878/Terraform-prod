resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = var.cluster_id
  replication_group_description = var.group_description
  engine_version                = var.engine_version
  node_type                     = var.cluster_type
  port                          = var.port
  parameter_group_name          = var.parameter_group_name
  automatic_failover_enabled    = true
  security_group_ids            = var.security_group_ids
  subnet_group_name             = "${aws_elasticache_subnet_group.Subnet.name}"
  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 2
  }
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_elasticache_subnet_group" "Subnet" {
  name = "redis-subnet"
  subnet_ids = var.public_subnets
}

resource "aws_elasticache_replication_group" "redis-node" {
  automatic_failover_enabled    = true
  availability_zones            = var.node_zones
  replication_group_description = var.group_description
  replication_group_id          = var.replication_group_id
  engine_version                = var.engine_version
  node_type                     = var.node_type
  number_cache_clusters         = 2
  parameter_group_name          = var.parameter_group_name_node
  port                          = var.port
  security_group_ids            = var.security_group_ids
  subnet_group_name             = "${aws_elasticache_subnet_group.Subnet.name}"
  lifecycle {
    ignore_changes = [number_cache_clusters]
  }
}
