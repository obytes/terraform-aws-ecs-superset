variable "prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

# KMS
variable "kms_arn" {
  type = string
}

# Network
variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_cluster" {
  type = map(string)
}

variable "app_ecs_params" {
  type = map(string)
}

variable "ecr_repository_url" {
  type = string
}

variable "app_sg" {}

variable "env_vars" {}

variable "public_alb" {
  type = map(string)
}

variable "ssm_role_arn" {
  type = string
}

variable "service_discovery" {
  type = any
}

variable "file_system_id" {
  type = string
}

variable "efs_access_point_id" {
  type = string
}

variable "worker_secrets_arn" {
  type = string
}

variable "alb_hostname" {
  type = map(string)
}

