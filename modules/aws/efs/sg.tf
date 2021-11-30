resource "aws_security_group" "efs" {
  name        = "${local.prefix}-efs-sg"
  description = "${local.prefix} EFS service"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.prefix}-efs"
    },
  )
}

resource "aws_security_group_rule" "allow_svc_to_efs" {
  for_each                 = var.service_sg_id
  description              = "Allow Traffic from Service nodes to EFS"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = each.value
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 2049
  to_port                  = 2049
}
