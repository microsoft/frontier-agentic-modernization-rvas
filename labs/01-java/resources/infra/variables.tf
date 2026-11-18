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

variable "vm_size" {
  type        = string
  description = "Azure VM size. Standard_D4s_v3 (4 vCPU / 16 GB) recommended — Oracle needs ≥2 GB RAM free."
  default     = "Standard_D4s_v3"
}

variable "admin_username" {
  type        = string
  description = "Linux admin username."
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Password for the admin user. Must be 12+ characters with upper, lower, digit, and special character. No underscores."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group to create."
  default     = "wth-photoalbum-vm-rg"
}

# ── Azure Database for PostgreSQL (Ora2Pg target) ─────────────────────────────
variable "db_admin_username" {
  type        = string
  description = "Administrator username for the target Azure Database for PostgreSQL Flexible Server."
  default     = "psqladmin"
}

variable "db_admin_password" {
  type        = string
  description = "Administrator password for the target Azure Database for PostgreSQL Flexible Server. Must be 12+ characters with upper, lower, digit, and special character. No underscores."
  default     = "CHANGEMEPsql2!"
  sensitive   = true
}

