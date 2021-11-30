resource "aws_security_group" "ecs-service" {
  name        = "${local.prefix}-ecs-sg"
  description = "${local.prefix} ECS Task SG"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ecs_service_security_group_ingress_rules
    content {
      protocol        = "tcp"
      description     = ingress.value["description"]
      from_port       = ingress.value["from_port"]
      to_port         = ingress.value["to_port"]
      security_groups = ingress.value["security_groups"]
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.prefix}-sg"
    },
  )
}
