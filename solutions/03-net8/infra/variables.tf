variable "prefix" {
  type        = string
  description = "Short prefix used for all resource names. Keep it short (≤8 chars) and lowercase."
  default     = "rvas"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources into."
  default     = "swedencentral"
}

variable "app_image" {
  type        = string
  description = "Container image for the eShopOnWeb web application."
  default     = "ghcr.io/microsoft/frontier-agentic-modernization-rvas/eshoponweb:latest"
}

variable "api_image" {
  type        = string
  description = "Container image for the eShopOnWeb public API."
  default     = "ghcr.io/microsoft/frontier-agentic-modernization-rvas/eshoponweb-api:latest"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group to create."
  default     = "rvas-eShopOnWeb-aca-rg"
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

variable "redis_sku_name" {
  type        = string
  description = "Azure Managed Redis SKU."
  default     = "Balanced_B0"
}

variable "redis_high_availability_enabled" {
  type        = bool
  description = "Whether Azure Managed Redis should use high availability."
  default     = false
}
