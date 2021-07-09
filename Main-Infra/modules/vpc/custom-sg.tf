resource "aws_security_group" "https_inbound_sg" {
  name = "http_inbound"
  description = "Allow HTTPS from Anywhere"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.ip_range}"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["::/0",]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${concat(aws_vpc.default.*.id, [""])[0]}"
  tags = {
      Name = "Http_inbound"
  }
}

resource "aws_security_group" "node_sg" {
  name        = "node_exporter"
  description = "Allow HTTP for node-exporter metrics"
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["${var.node_ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "Node_exporter"
  }
}

resource "aws_security_group" "ssh_sg" {
  name        = "ssh_inbound"
  description = "Allow SSH to host from approved ranges"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "ssh_inbound"
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "grafana_sg"
  description = "Allow SSH to host from approved ranges"
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${var.prometheus_ip_range}"]
  }
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["${var.alert_manager_ip_range}"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.grafana_ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "grafana_sg"
  }
}

resource "aws_security_group" "postgres_sg" {
  name        = "postgres_sg"
  description = "Allow SSH to host from approved ranges"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.postgres_ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "postgres_sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "external_alb_sg"
  description = "Allows external access to LB"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "external_alb_sg"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "Allows connection to redis nodes"
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["${var.redis_ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "redis_sg"
  }
}

resource "aws_security_group" "elasticsearch_sg" {
  name        = "elasticsearch_sg"
  description = "Allow HTTPS from Anywhere"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "Elasticsearch_sg"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow access from Anywhere"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "bastion_sg"
  }
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb_sg"
  description = "Allow access to MongoDB from Anywhere"
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${var.ip_range}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = concat(aws_vpc.default.*.id, [""])[0]
  tags = {
    Name = "mongodb_sg"
  }
}