output "app_url" {
  description = "Public URL of the Photo Album Container App."
  value       = "https://${azurerm_container_app.photoalbum.ingress[0].fqdn}"
}

output "container_app_fqdn" {
  description = "FQDN of the Container App ingress."
  value       = azurerm_container_app.photoalbum.ingress[0].fqdn
}

output "postgresql_fqdn" {
  description = "Fully-qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.postgres.name
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault (value of AZURE_KEYVAULT_ENDPOINT)."
  value       = azurerm_key_vault.kv.vault_uri
}
