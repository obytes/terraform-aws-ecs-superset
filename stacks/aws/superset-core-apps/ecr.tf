module "ecr" {
  source          = "../../../modules/aws/ecr"
  repository_name = var.repository_name
}
