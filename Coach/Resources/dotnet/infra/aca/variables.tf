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
  description = "Container image to deploy in the Container App (e.g. ghcr.io/org/contoso-university:latest)."
  default     = "ghcr.io/cmendible/github-copilot-modernization/contoso-university:latest"
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

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group to create."
  default     = "wth-contoso-aca-rg"
}

variable "openai_location" {
  type        = string
  description = "Azure region for the Azure OpenAI account. gpt-4.1-mini is currently available in Sweden Central and East US 2."
  default     = "swedencentral"
}

variable "openai_deployment_name" {
  type        = string
  description = "Name of the Azure OpenAI model deployment."
  default     = "gpt-4.1-mini"
}

variable "openai_model_version" {
  type        = string
  description = "Version of the gpt-4.1-mini model to deploy."
  default     = "2025-04-14"
}

variable "openai_deployment_capacity" {
  type        = number
  description = "Capacity (TPM in thousands) for the model deployment."
  default     = 50
}
