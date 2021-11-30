resource "aws_security_group" "default" {
  name        = "${var.prefix}-sg"
  description = "Allow 5432 in VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"

    security_groups = var.security_group
  }


  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"


    cidr_blocks = [
      var.vpn_ass_cidr
    ]

  }


  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${var.identifier}-sg"
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "${var.prefix}-param-group"
  family = var.family

  parameter {
    name  = "rds.force_admin_logging_level"
    value = "info"
  }

  parameter {
    name  = "track_functions"
    value = "all"
  }
}

resource "aws_db_instance" "default" {
  depends_on = [
    aws_security_group.default,
  ]

  identifier                 = var.identifier
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  multi_az                   = var.multi_az
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  monitoring_role_arn        = module.rds-monitoring-role.arn

  # disk
  storage_type      = var.storage_type
  iops              = var.iops
  allocated_storage = var.allocated_storage
  storage_encrypted = true
  kms_key_id        = var.kms

  name                    = var.db_name
  username                = var.username
  password                = var.password
  backup_retention_period = "30"

  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
  ]

  db_subnet_group_name = aws_db_subnet_group.default.id

  parameter_group_name = aws_db_parameter_group.default.id

  monitoring_interval = var.monitoring_interval

  lifecycle {
    ignore_changes = [
      password,
      parameter_group_name,
      tags,
    ]
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "${var.prefix}-subnet-group"
  description = "Main group of subnets for ${var.identifier}"

  subnet_ids = var.subnet_ids
}

data "aws_iam_policy_document" "rds_trust_policy" {
  statement {
    sid = "RDSEnhancedMonitoringRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "monitoring.rds.amazonaws.com",
      ]
    }
  }
}

module "rds-monitoring-role" {
  source             = "../iam/role"
  name               = "${var.prefix}-moni-role"
  policy_to_attach   = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  assume_role_policy = data.aws_iam_policy_document.rds_trust_policy.json
}

