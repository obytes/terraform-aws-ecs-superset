variable "repository_name" {
  type = string
}

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

variable "worker_ecs_params" {
  type = map(string)
}

variable "worker_beat_ecs_params" {
  type = map(string)
}

variable "app_ecs_params" {
  type = map(string)
}

variable "alb_security_group" {}

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
