resource "aws_efs_mount_target" "default" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = element(var.private_subnet_ids, count.index)
  security_groups = [aws_security_group.efs.id]
}
