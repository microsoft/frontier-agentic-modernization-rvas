output "app_url" {
  description = "Public URL of the eShopOnWeb Container App."
  value       = "https://${azurerm_container_app.eshop.ingress[0].fqdn}"
}

output "container_app_fqdn" {
  description = "FQDN of the eShopOnWeb Container App ingress."
  value       = azurerm_container_app.eshop.ingress[0].fqdn
}

output "api_container_app_fqdn" {
  description = "Internal FQDN of the eShopOnWeb API Container App."
  value       = azurerm_container_app.api.ingress[0].fqdn
}

output "sql_server_fqdn" {
  description = "Fully-qualified domain name of the Azure SQL Server."
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_database_names" {
  description = "Names of the Azure SQL databases."
  value = {
    catalog  = azurerm_mssql_database.catalog.name
    identity = azurerm_mssql_database.identity.name
  }
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "openai_endpoint" {
  description = "Endpoint of the Azure OpenAI account (used as AzureOpenAI__Endpoint)."
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_deployment_name" {
  description = "Name of the Azure OpenAI model deployment."
  value       = azurerm_cognitive_deployment.gpt41_mini.name
}

output "redis_hostname" {
  description = "Azure Managed Redis hostname."
  value       = azurerm_managed_redis.cache.hostname
}

output "redis_port" {
  description = "TLS port of the Azure Managed Redis default database."
  value       = azurerm_managed_redis.cache.default_database[0].port
}
