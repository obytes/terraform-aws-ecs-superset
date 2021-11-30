output "db_information" {
  value = module.db.db
}

output "database_url" {
  value = "postgresql://${var.db_config["username"]}:${var.db_config["password"]}@${module.db.db["endpoint"]}/${module.db.db_name}"
}

output "database_hostname" {
  value = module.db.hostname
}

output "db_info" {
  value = module.db.db
}
