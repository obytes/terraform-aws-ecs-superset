terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # The S3 bucket where state-files are kept
    #### NOTE: this uses the old admithub.com format, not the future/new one
    bucket = "terraform-statefiles.admithub.com"

    # DynamoDB tables where the lock is kept
    #######################################################################################
    ### It is VITALLY IMPORTANT that the key be unique and map to the folder hierarchy! ###
    #######################################################################################
    key = "superset/state-lock/terraform.tfstate"
    ### Pay attention to the comment above ###

    # The rest of the DynamoDB table configs
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

}

provider "aws" {
  region = "us-east-1"
}


locals  {
  prefix = "superset"
  vpc_id = "vpc-003d3e12a78dceefc"
  db_identifier = "superset-db"
  allocated_storage = 10
  cidr_block = "10.0.0.0/16"
  superset_db_config = {
    "db_name": "test",
    "username": "test"
    "password": "mkosmdlSM!1d"
  }
  private_subnet_ids = ["subnet-04c0045ae43a3b13c", "subnet-01cd2f7d5c38ef88f"]
  kms_arn = "arn:aws:kms:us-east-1:962178857523:key/mrk-e29d42fb1e3549b6be0fd745a6571ca4"
  instance_class = "db.m5.large"

  common_tags = {
    "owner": "data",
    "managed": "terraform"
  }
  node_type = { # TODO
    "whatisthis": "r5.xlarge"
  } 
  parameter_group_name = { # TODO
    "whatisthis": "whatishits"
  }
  engine_version = { # TODO
    "whatisthis": "whatishits" 
  }

  env_vars = {}
  service_discovery = ""
  ecs_cluster = { # TODO:
    "": ""
  }

  public_alb = {
    "": ""
  }
  alb_sg_id = ""
  worker_secrets_arn = ""
  ssm_role_arn = ""
}



module "superset-db" {
  source            = "./stacks/aws/superset-db"
  prefix            = local.prefix
  vpc_id            = local.vpc_id
  identifier        = local.db_identifier
  allocated_storage = local.allocated_storage
  cidr_block        = local.cidr_block
  db_config         = local.superset_db_config
  subnet_ids        = local.private_subnet_ids
  kms               = local.kms_arn
  instance_class    = local.instance_class
  security_group = [
    # module.base.default_sg_id,
    # module.superset-core.ecs_service_security_group_id,
    # module.superset-core.app_service_security_group_id,
    # module.superset-core.worker_beat_service_security_group_id,
    # data.terraform_remote_state.east1_adm.outputs.argo_sg_id
  ]
  vpn_ass_cidr = "10.0.0.0/16"
}

# module "superset-redis" {
#   source               = "./modules/aws/redis"
#   prefix               = local.prefix
#   common_tags          = local.common_tags
#   vpc_id               = local.vpc_id
#   private_subnet_ids   = local.private_subnet_ids
#   node_type            = local.node_type
#   parameter_group_name = local.parameter_group_name
#   engine_version       = local.engine_version
#   port                 = 6379
#   allowed_security_groups = {
#     "worker"      = module.superset-core.ecs_service_security_group_id
#     "app"         = module.superset-core.app_service_security_group_id
#     "worker_beat" = module.superset-core.worker_beat_service_security_group_id
#   }
# }
# 
# module "superset-core" {
#   source             = "./stacks/aws/superset-core-apps"
#   repository_name    = join("-", [local.prefix, "superset"])
#   prefix             = local.prefix
#   common_tags        = local.common_tags
#   kms_arn            = local.kms_arn
#   vpc_id             = local.vpc_id
#   private_subnet_ids = local.private_subnet_ids
#   service_discovery  = local.service_discovery
#   ecs_cluster        = local.ecs_cluster
#   env_vars           = local.env_vars
#   public_alb         = local.public_alb
#   worker_ecs_params = {
#     desired_count  = 1
#     cpu            = 512
#     memory         = 1024
#     port           = 8088
#     container_name = "superset-wrk"
#   }
#   worker_beat_ecs_params = {
#     desired_count  = 1
#     cpu            = 512
#     memory         = 1024
#     port           = 8088
#     container_name = "superset-beat"
#   }
#   app_ecs_params = {
#     desired_count  = 1
#     cpu            = 2048
#     memory         = 4096
#     port           = 8088
#     container_name = "superset-app"
#   }
#   alb_security_group = local.alb_sg_id
#   ssm_role_arn       = local.ssm_role_arn # data.terraform_remote_state.east1_adm.outputs.ssm_role_arn
#   worker_secrets_arn = local.worker_secrets_arn
# }
