output "backend_pool_id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_lb_backend_address_pool.backend_address_pool.*.id, list("")), 0)
}
