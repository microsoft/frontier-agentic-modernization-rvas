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

variable "app_image" {
  type        = string
  description = "Container image to deploy in the Container App."
  default     = "ghcr.io/cmendible/github-copilot-modernization/photo-album:latest"
}

variable "db_admin_username" {
  type        = string
  description = "Administrator login for the PostgreSQL Flexible Server."
  default     = "photoalbumadmin"
}

variable "db_admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for the PostgreSQL Flexible Server. Must be 8-128 characters with upper, lower, digit, and special character."
}

variable "github_username" {
  type        = string
  description = "GitHub username used to authenticate against ghcr.io."
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub Personal Access Token (PAT) with read:packages scope, used to pull the image from ghcr.io."
}
