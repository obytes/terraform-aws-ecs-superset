###############################################
#            REDIS SECURITY GROUP             |
#       Default security group for Redis      |
###############################################
resource "aws_security_group" "default" {
  name        = join("-", [local.prefix, "redis-sg"])
  description = "Default redis security group"
  vpc_id      = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  lifecycle {
    ignore_changes = [
      ingress,
    ]
  }

  tags = merge(local.common_tags, tomap({ Name = join("-", [local.prefix, "sg"]) }))
}

resource "aws_security_group_rule" "ingress_sgs_access" {
  for_each                 = var.allowed_security_groups
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "TCP"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.default.id
  type                     = "ingress"
}

###############################################
#           SECURITY GROUPS INGRESS           |
#    Allow ingress comming from cidr block    |
###############################################
resource "aws_security_group_rule" "ingress_cidr" {
  for_each          = var.allowed_cidr_blocks
  from_port         = var.port
  to_port           = var.port
  protocol          = "TCP"
  security_group_id = aws_security_group.default.id
  cidr_blocks       = each.value
  type              = "ingress"
}