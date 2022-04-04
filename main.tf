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


locals {
  prefix            = "superset"
  vpc_id            = "vpc-003d3e12a78dceefc"
  db_identifier     = "superset-db"
  allocated_storage = 10
  cidr_block        = "10.0.0.0/16"
  superset_db_config = {
    "db_name" : "superset",
    "username" : "superset"
    "password" : jsondecode(data.aws_secretsmanager_secret_version.prod.secret_string)["DATABASE_PASSWORD"]
  }
  private_subnet_ids = ["subnet-04c0045ae43a3b13c", "subnet-01cd2f7d5c38ef88f"]
  public_subnet_ids  = ["subnet-03d8ff6c1c465ff10", "subnet-0591f63ac09d0e666"]
  kms_arn            = "arn:aws:kms:us-east-1:962178857523:key/mrk-e29d42fb1e3549b6be0fd745a6571ca4"
  instance_class     = "db.m5.large"

  common_tags = {
    "owner" : "data",
    "managed" : "terraform",
    "env" : "prod",
    "region": "us-east-1"
  }
  node_type = { # TODO
    "prod" : "cache.r5.large"
  }
  parameter_group_name = { # TODO
    "prod" : "default.redis6.x"
  }
  engine_version = { # TODO
    "prod" : "6.x"
  }

  env_vars          = {
    "COMPOSE_PROJECT_NAME": "superset",
    "DATABASE_DIALECT": "postgres",
    "DATABASE_USER": local.superset_db_config.username,
    #"DATABASE_PASSWORD": from secret via ECS magic.
    #"DATABASE_HOST": from secret via ECS magic.
    "DATABASE_PORT": 5432,
    "DATABASE_DB": "superset",
    #"REDIS_HOST": from secret via ECS magic.
    "REDIS_PORT": module.superset-redis.redis_port,
    "FLASK_ENV": "production",
    "SUPERSET_ENV": "production",
    "SUPERSET_LOAD_EXAMPLES": "false",
    "CYPRESS_CONFIG": "false",
    "SUPERSET_PORT": "8088",
    "PYTHONPATH": "/app/pythonpath:/app/docker/pythonpath_dev",
    "REDIS_CELERY_DB": "1"
    "REDIS_RESULTS_DB": "2"
  }
  service_discovery = {
    "namespace":  {
      "namespace_id": "ns-ofelzbhmef4zwfzt" # supserOnAWS.local
    }
  }
  public_alb = {
    "listener_arn" : ""
  }
  alb_sg_id          = aws_security_group.public.id
  worker_secrets_arn = "arn:aws:secretsmanager:us-east-1:962178857523:secret:superset-prod-PiUOWN"
  ssm_role_arn       = ""

  alb_hostname =  {
    "prod": "superset.data.mainstay.com"
  }

  domain_zone_id = "Z0012336234LLNF1J3R5N" # data.mainstay.com
  domain = "superset.data.mainstay.com"
}

data "aws_secretsmanager_secret" "prod" {
  arn = "arn:aws:secretsmanager:us-east-1:962178857523:secret:superset-prod-PiUOWN"
}

data "aws_secretsmanager_secret_version" "prod" {
  secret_id = data.aws_secretsmanager_secret.prod.id
}

resource "aws_ecs_cluster" "superset" {
  name = "superset-ecs-cluster"
}
resource aws_ecs_cluster_capacity_providers "superset" {
  cluster_name = aws_ecs_cluster.superset.name

  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_security_group" "public" {
  name = "superset-public-alb"
  description = "Allow access to Superset ALB"
  vpc_id = local.vpc_id

  ingress {
    description      = "HTTPS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "public" {
  name = "supserset-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.public.id]
  subnets = local.public_subnet_ids
  
  enable_deletion_protection = true

  tags = local.common_tags
  tags_all = local.common_tags

  access_logs {
    bucket = "superset-logs"
    prefix = "demo"
    enabled = false
  }
}

resource "aws_route53_record" "cname" {
  zone_id = local.domain_zone_id
  name    = local.domain
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.public.dns_name]
}

resource "aws_acm_certificate" "public" {
  domain_name       = aws_route53_record.cname.name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.public.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code = "404"
    }
  }
}
  
resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
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
    aws_security_group.public.id,
    #module.base.default_sg_id,
    module.superset-core.ecs_service_security_group_id,
    module.superset-core.app_service_security_group_id,
    module.superset-core.worker_beat_service_security_group_id,
    #data.terraform_remote_state.east1_adm.outputs.argo_sg_id
  ]
  vpn_ass_cidr = "10.0.0.0/16"
}

module "superset-redis" {
  source               = "./modules/aws/redis"
  prefix               = local.prefix
  common_tags          = local.common_tags
  vpc_id               = local.vpc_id
  private_subnet_ids   = local.private_subnet_ids
  node_type            = local.node_type
  parameter_group_name = local.parameter_group_name
  engine_version       = local.engine_version
  port                 = 6379
  allowed_security_groups = {
    "worker"      = module.superset-core.ecs_service_security_group_id
    "app"         = module.superset-core.app_service_security_group_id
    "worker_beat" = module.superset-core.worker_beat_service_security_group_id
  }
}

module "superset-core" {
  source             = "./stacks/aws/superset-core-apps"
  repository_name    = "superset"
  prefix             = local.prefix
  common_tags        = local.common_tags
  kms_arn            = local.kms_arn
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids
  service_discovery  = local.service_discovery
  ecs_cluster        = { "name": aws_ecs_cluster.superset.name }
  env_vars           = local.env_vars
  public_alb         = { "listener_arn": aws_lb_listener.public_https.arn }
  worker_ecs_params = {
    desired_count  = 1
    cpu            = 512
    memory         = 1024
    port           = 8088
    container_name = "superset-wrk"
  }
  worker_beat_ecs_params = {
    desired_count  = 1
    cpu            = 512
    memory         = 1024
    port           = 8088
    container_name = "superset-beat"
  }
  app_ecs_params = {
    desired_count  = 1
    cpu            = 2048
    memory         = 4096
    port           = 8088
    container_name = "superset-app"
  }
  alb_security_group = local.alb_sg_id
  ssm_role_arn       = local.ssm_role_arn # data.terraform_remote_state.east1_adm.outputs.ssm_role_arn
  worker_secrets_arn = local.worker_secrets_arn
  alb_hostname       = local.alb_hostname
}
