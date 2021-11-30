data "aws_secretsmanager_secret" "worker_secrets" {
  arn = var.worker_secrets_arn
}

data "aws_secretsmanager_secret_version" "worker_secrets" {
  secret_id = data.aws_secretsmanager_secret.worker_secrets.id
}
