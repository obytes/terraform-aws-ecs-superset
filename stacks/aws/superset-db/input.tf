variable "prefix" {}

variable "identifier" {}

variable "allocated_storage" {}

variable "vpc_id" {}

variable "cidr_block" {}

variable "subnet_ids" {
  description = "List of subnet IDs to be used for RDS creation"
  type        = list(string)
}

variable "security_group" {
  description = "SGs to permission"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class or type"
  default     = "db.m4.xlarge"
}


variable "kms" {
  description = "KMS Arn"
}

variable "db_config" {
}


variable "vpn_ass_cidr" {
}
