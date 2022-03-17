locals  {
  # TODO: Where should this come from?
  alb_hostname = {
    "prod": "superset.prod.alb"
  }
}

resource "aws_alb_listener_rule" "api" {
  listener_arn = var.public_alb["listener_arn"]
  priority     = 98
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.superset.id
  }
  condition {
    host_header {
      values = [local.alb_hostname[var.common_tags["env"]]]
    }
  }
}


resource "aws_alb_target_group" "superset" {
  name                 = join("-", [var.prefix, "tg"])
  port                 = 8088
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 5
  target_type          = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    port                = 8088
    interval            = 60
  }


  tags = merge(var.common_tags, tomap({ Name = join("-", [
    var.prefix,
  "tg"]) }))
}

