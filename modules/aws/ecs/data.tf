data "aws_caller_identity" "current" {
}

data "aws_ecs_task_definition" "default" {
  task_definition = aws_ecs_task_definition.default.family

  depends_on = [aws_ecs_task_definition.default]
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
