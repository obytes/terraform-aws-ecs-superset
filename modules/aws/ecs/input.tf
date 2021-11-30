locals {
  prefix      = var.prefix
  common_tags = var.common_tags
}

# Common
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

variable "ecs_service_subnet_ids" {
  type = list(string)
}

variable "ecs_service_security_group_ingress_rules" {
  type    = any
  default = []
}

# ECS
variable "ecs_cluster" {
  type = map(string)
}

variable "platform_version" {
  type    = string
  default = "1.4.0"
}

variable "desired_count" {
  type = string
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "container_definitions" {}


# IAM
variable "extra_iam" {
  type    = any
  default = []
}

variable "load_balancer" {
  type    = any
  default = []
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = string
}

variable "alb_target_group_id" {
  type    = any
  default = null
}

variable "service_discovery" {
  type    = any
  default = null
}

variable "file_system_id" {
  type = string
}

variable "root_directory" {
  type = string
}

variable "efs_sg_id" {
  type    = string
  default = null
}

variable "efs_access_point_id" {
  type = string
}
