module "db" {
  source            = "../../../modules/aws/rds"
  prefix            = local.prefix
  vpc_id            = var.vpc_id
  identifier        = var.identifier
  allocated_storage = var.allocated_storage
  cidr_block        = var.cidr_block
  db_name           = var.db_config["db_name"]
  username          = var.db_config["username"]
  password          = var.db_config["password"]
  subnet_ids        = var.subnet_ids
  kms               = var.kms
  instance_class    = var.instance_class
  security_group    = var.security_group
  vpn_ass_cidr      = var.vpn_ass_cidr
}
