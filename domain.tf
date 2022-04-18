locals {
  mainstay_zone_id = "9d33e053c503cfa607da1a4765df79c8" # mainstay.com in cloudflare
}

resource "cloudflare_record" "analytics" {
  zone_id = local.mainstay_zone_id
  name    = "analytics"
  value   = aws_lb.public.dns_name
  type    = "CNAME"
  ttl     = 300
}

resource "aws_acm_certificate" "analytics" {
  domain_name       = "analytics.mainstay.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
resource "cloudflare_record" "analyitcs_validation" {
  for_each = {
    for dvo in aws_acm_certificate.analytics.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  value           = each.value.record
  type            = each.value.type
  zone_id         = local.mainstay_zone_id
  ttl             = 60
}
