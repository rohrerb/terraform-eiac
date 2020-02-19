output "dns" {
  value = element(concat(azurerm_sql_server.sql_server.*.fully_qualified_domain_name, list("")), 0)
}

output "password" {
  value = element(concat(random_password.sa_password.*.result, list("")), 0)
}

 