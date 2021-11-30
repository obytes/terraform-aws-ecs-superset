locals {
  prefix      = join("-", [var.prefix, "efs"])
  common_tags = merge(var.common_tags, tomap({ Stack = "Superset EFS" }))
}
