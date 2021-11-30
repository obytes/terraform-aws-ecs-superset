resource "aws_elasticache_cluster" "default" {
  cluster_id           = join("-", [local.prefix, "redis"])
  engine               = var.engine
  node_type            = lookup(var.node_type, var.common_tags["env"])
  num_cache_nodes      = 1
  parameter_group_name = lookup(var.parameter_group_name, var.common_tags["env"])
  engine_version       = lookup(var.engine_version, var.common_tags["env"])
  port                 = var.port
  security_group_ids = [
    aws_security_group.default.id,
  ]
  subnet_group_name = aws_elasticache_subnet_group.default.name

  tags = merge(local.common_tags, tomap({ Name = join("-", [local.prefix, "cluster"]) }))
}