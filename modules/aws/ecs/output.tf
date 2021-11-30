output "ecs_service_name" {
  value = aws_ecs_service.default.name
}

output "ecs_service_security_group_id" {
  value = aws_security_group.ecs-service.id
}
