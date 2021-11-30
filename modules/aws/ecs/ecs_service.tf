resource "aws_ecs_service" "default" {
  name                   = local.prefix
  cluster                = var.ecs_cluster["name"]
  task_definition        = aws_ecs_task_definition.default.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  platform_version       = var.platform_version
  enable_execute_command = true
  dynamic "service_registries" {
    for_each = var.service_discovery != null ? var.service_discovery : {}
    content {
      registry_arn   = aws_service_discovery_service._[0].arn
      container_name = var.container_name
    }
  }
  network_configuration {
    security_groups = [aws_security_group.ecs-service.id]
    subnets         = var.ecs_service_subnet_ids
  }
  dynamic "load_balancer" {
    for_each = var.alb_target_group_id != null ? var.alb_target_group_id : {}
    content {
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
      target_group_arn = load_balancer.value["alb_target_group_id"]
    }
  }
}
