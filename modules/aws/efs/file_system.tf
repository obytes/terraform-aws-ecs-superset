resource "aws_efs_file_system" "default" {
  creation_token = "superset-service-efs"

  encrypted        = false
  throughput_mode  = "bursting"
  performance_mode = "maxIO"

  tags = merge(local.common_tags, tomap({ Name = local.prefix }))
}
