module "app_efs" {
  source      = "../../../modules/aws/efs/"
  common_tags = var.common_tags
  service_sg_id = {
    superset_app  = module.app.app_service_security_group_id
    superset_wrk  = module.worker.ecs_service_security_group_id
    superset_beat = module.worker_beat.beat_ecs_service_security_group_id
  }
  private_subnet_ids = var.private_subnet_ids
  prefix             = var.prefix
  vpc_id             = var.vpc_id
  kms_arn            = var.kms_arn
}
