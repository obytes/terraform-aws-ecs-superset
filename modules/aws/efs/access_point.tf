resource "aws_efs_access_point" "default" {
  file_system_id = aws_efs_file_system.default.id
  tags = {
    Name = join("-", [local.prefix, "mounts"])
  }
}
