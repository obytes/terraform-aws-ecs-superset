variable "private_subnet_ids" {
  type = list(string)
}

variable "service_sg_id" {
  type = map(string)
}

variable "common_tags" {
  type = map(string)
}

variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "kms_arn" {
  type = string
}
