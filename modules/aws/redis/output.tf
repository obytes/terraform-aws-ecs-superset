output "endpoint_address" {
  value = aws_elasticache_cluster.default.cache_nodes[0]["address"]
}

output "redis_sg_id" {
  value = aws_security_group.default.id
}

output "redis_port" {
  value = aws_elasticache_cluster.default.port
}
