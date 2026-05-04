output "app_url" {
  description = "Public URL of the Contoso University Container App."
  value       = "https://${azurerm_container_app.contoso.ingress[0].fqdn}"
}

output "container_app_fqdn" {
  description = "FQDN of the Container App ingress."
  value       = azurerm_container_app.contoso.ingress[0].fqdn
}

output "sql_server_fqdn" {
  description = "Fully-qualified domain name of the Azure SQL Server."
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the Azure SQL Database."
  value       = azurerm_mssql_database.contoso.name
}

output "servicebus_namespace_fqdn" {
  description = "Fully-qualified Service Bus namespace hostname (used as AzureServiceBus__FullyQualifiedNamespace)."
  value       = "${azurerm_servicebus_namespace.sb.name}.servicebus.windows.net"
}

output "storage_account_blob_endpoint" {
  description = "Primary blob service endpoint of the Storage Account (used as AzureStorageBlob__Endpoint)."
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}
