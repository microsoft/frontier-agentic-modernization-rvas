variable "prefix" {
  type        = string
  description = "Short prefix used for all resource names. Keep it short (≤8 chars) and lowercase."
  default     = "wth"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources into."
  default     = "swedencentral"
}

variable "dms_location" {
  type        = string
  description = "Azure region for Azure Database Migration Service resources. Must be one of the regions supported by Microsoft.DataMigration/services."
  default     = "westeurope"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size. Standard_D2s_v3 (2 vCPU / 8 GB) is sufficient for IIS + SQL Express."
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  type        = string
  description = "Local administrator username for the Windows VM."
  default     = "azureadmin"
}

variable "admin_password" {
  type        = string
  description = "Local administrator password. Must meet Azure complexity requirements (12+ chars, upper, lower, digit, special)."
  sensitive   = true
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group to create."
  default     = "wth-contoso-vm-rg"
}

variable "sql_admin_login" {
  type        = string
  description = "SQL Authentication admin login for the target Azure SQL Server. Required by the DMS wizard for target connection."
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL Authentication admin password for the target Azure SQL Server. Required by the DMS wizard for target connection."
  sensitive   = true
  default     = "SqlTarget@2024!"
}

variable "sql_migration_password" {
  type        = string
  description = "Password for the 'dms_migration' SQL login created on SQL Server Express. Used by Azure DMS to connect to the source database."
  sensitive   = true
  default     = "DmsMigration@2024!"
}

