resource "aws_ecs_task_definition" "default" {
  family                   = local.prefix
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-role.arn
  execution_role_arn       = aws_iam_role.ecs-role.arn
  container_definitions    = var.container_definitions
  volume {
    name = "superset_app"
    efs_volume_configuration {
      file_system_id = var.file_system_id

      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999

      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }
}
