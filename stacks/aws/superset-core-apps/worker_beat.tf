module "worker_beat" {
  source                 = "./worker-beat"
  prefix                 = "prd-rdt-useast1-sprset-wrk-bt"
  common_tags            = var.common_tags
  kms_arn                = var.kms_arn
  vpc_id                 = var.vpc_id
  private_subnet_ids     = var.private_subnet_ids
  ecs_cluster            = var.ecs_cluster
  worker_beat_ecs_params = var.worker_beat_ecs_params
  service_discovery      = var.service_discovery
  ecr_repository_url     = module.ecr.repository_url
  env_vars               = var.env_vars
  ssm_role_arn           = var.ssm_role_arn
  file_system_id         = module.app_efs.file_system_id
  efs_access_point_id    = module.app_efs.efs_access_point_id
  worker_secrets_arn     = var.worker_secrets_arn
  worker_beat_sg = [
    {
      description : "allow the superset-app sg"
      from_port : 8088
      to_port : 8088
      security_groups : [
        module.app.app_service_security_group_id,
        var.alb_security_group,
        module.worker.ecs_service_security_group_id
      ]
    }
  ]
}
