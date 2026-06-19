output "public_ip" {
  description = "Public IP address of the ContosoUniversity VM."
  value       = azurerm_public_ip.pip.ip_address
}

output "app_url" {
  description = "URL to access the ContosoUniversity application."
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}

output "rdp_command" {
  description = "Command to open an RDP session to the VM (Windows) or mstsc shortcut."
  value       = "mstsc /v:${azurerm_public_ip.pip.ip_address}"
}

output "admin_username" {
  description = "Administrator username for RDP."
  value       = var.admin_username
}

output "setup_status" {
  description = "The custom script extension runs setup.ps1 after the VM starts. Allow 10–15 minutes for all components to install before accessing the app."
  value       = "Visit ${azurerm_public_ip.pip.ip_address} after ~15 minutes. Check extension logs in Azure Portal → VM → Extensions if the app is not reachable."
}

output "target_sql_database" {
  description = "Name of the target Azure SQL Database."
  value       = azurerm_mssql_database.contoso.name
}

output "dms_service_name" {
  description = "Name of the Azure Database Migration Service instance."
  value       = azurerm_database_migration_service.dms.name
}

output "dms_project_name" {
  description = "Name of the DMS migration project (SQL Server → Azure SQL DB)."
  value       = azurerm_database_migration_project.sql_to_sqldb.name
}

# ── Wizard helper outputs ─────────────────────────────────────────────────────
output "source_sql_private_ip" {
  description = "Private IP of the source SQL Server VM NIC."
  value       = azurerm_network_interface.nic.private_ip_address
}

output "source_sql_auth_type" {
  description = "Authentication type to use for the source SQL Server in the wizard."
  value       = "SQL Authentication"
}

output "source_sql_username" {
  description = "Source SQL login username for DMS."
  value       = "dms_migration"
}

output "source_sql_password" {
  description = "Source SQL login password for DMS."
  value       = var.sql_migration_password
  sensitive   = true
}

output "target_sql_server_for_wizard" {
  description = "Target Azure SQL Server hostname for the migration wizard."
  value       = azurerm_mssql_server.target.fully_qualified_domain_name
}

output "target_sql_auth_type" {
  description = "Authentication type to use for the target Azure SQL Server in the wizard."
  value       = "SQL Authentication"
}

output "target_sql_username" {
  description = "Target Azure SQL Server SQL Authentication admin login for the wizard."
  value       = var.sql_admin_login
}

output "target_sql_password" {
  description = "Target Azure SQL Server SQL Authentication admin password for the wizard."
  value       = var.sql_admin_password
  sensitive   = true
}

output "target_sql_database_for_wizard" {
  description = "Target Azure SQL Database name for the migration wizard."
  value       = azurerm_mssql_database.contoso.name
}

output "target_sql_auth_note" {
  description = "Authentication guidance for target SQL in the wizard."
  value       = "Use SQL Authentication in the DMS wizard for the target connection."
}

