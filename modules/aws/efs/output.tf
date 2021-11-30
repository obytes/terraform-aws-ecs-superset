output "file_system_id" {
  value = aws_efs_file_system.default.id
}

output "efs_sg_id" {
  value = aws_security_group.efs.id
}

output "efs_access_point_id" {
  value = aws_efs_access_point.default.id
}
