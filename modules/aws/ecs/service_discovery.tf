resource "aws_service_discovery_service" "_" {
  count = var.service_discovery != null ? 1 : 0
  name  = join("-", [var.common_tags["env"], var.container_name])

  dns_config {
    namespace_id = var.service_discovery.namespace.namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
