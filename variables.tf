variable "location" {
  type        = string
  default     = "UK South"
  description = "default resources location"
}
 
variable "resource_group_name" {
  type        = string
  description = "resource group name"
}
 
variable "storage_account_name" {
  type        = string
  description = "storage account name"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subsscription Id"
}

variable "azure_keyvault_id" {
  type        = string
  description = "Azure Subscription Id"
}