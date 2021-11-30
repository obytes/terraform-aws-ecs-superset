resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ecs/${local.prefix}"
  retention_in_days = local.common_tags["env"] == "prd" ? 0 : 30
  kms_key_id        = var.kms_arn

  tags = local.common_tags
}
