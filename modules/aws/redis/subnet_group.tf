###############################################
#              REDIS SUBNET GROUP             |
###############################################
resource "aws_elasticache_subnet_group" "default" {
  name       = join("-", [local.prefix, "redis-subnet-grp"])
  subnet_ids = var.private_subnet_ids
}