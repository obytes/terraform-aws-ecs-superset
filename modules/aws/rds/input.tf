variable "prefix" {
  type = string
}
variable "identifier" {}

variable "allocated_storage" {}

variable "vpc_id" {}

variable "cidr_block" {}

variable "db_name" {
  description = "Database name created on RDS"
}

variable "username" {
  description = "Username used for RDS Database"
}

variable "password" {
  description = "Password used for RDS Database"
}

variable "subnet_ids" {
  description = "List of subnet IDs to be used for RDS creation"
  type        = list(string)
}

variable "security_group" {
  description = "SGs to permission"
  type        = list(string)
}

variable "storage_type" {
  description = "Options: standard (magnetic), gp2 (general purpose SSD), io1 (provisioned IOPS SSD)"
  default     = "gp2"
}

variable "iops" {
  description = "Provisioned IOPS Storage"
  default     = "0"
}

variable "engine" {
  description = "RDS Database Engine (Defaults to PostgreSQL)"
  default     = "postgres"
}

variable "engine_version" {
  description = "RDS Engine version (e.g 9.5.4)"
  default     = "13.3"
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval"
  default     = "60"
}

variable "instance_class" {
  description = "Instance class or type"
  default     = "db.m4.xlarge"
}

variable "family" {
  description = "Parameter group family"
  default     = "postgres13"
}

variable "kms" {
  description = "KMS Arn"
}

variable "multi_az" {
  description = "multi-AZ for the RDS instance"
  default     = "false"
}

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  default     = "false"
}
variable "vpn_ass_cidr" {
  type        = string
  description = "vpn associate network cidr "
}


