locals {

  templates_path = join("/", [path.module, "templates", "test.sh"])
  prefix         = var.prefix
  cluster_name = {
    "qa"   = "raedata-redis"
    "prod" = "raedata-redis"
  }
  common_tags = merge(var.common_tags, tomap({ module = "elastic-cache" }))

}
