output "db" {
  value = (tomap({
    id       = element(concat(aws_db_instance.default.*.id, tolist([""])), 0),
    address  = element(concat(aws_db_instance.default.*.address, tolist([""])), 0),
    arn      = element(concat(aws_db_instance.default.*.arn, tolist([""])), 0),
    endpoint = element(concat(aws_db_instance.default.*.endpoint, tolist([""])), 0)
    port     = element(concat(aws_db_instance.default.*.port, tolist([""])), 0)
  }))
}

output "db_name" {
  value = var.db_name
}
