output "ecs_service_security_group_id" {
  value = module.worker.ecs_service_security_group_id
}

output "app_service_security_group_id" {
  value = module.app.app_service_security_group_id
}

output "worker_beat_service_security_group_id" {
  value = module.worker_beat.beat_ecs_service_security_group_id
}
