variable "name" {
  description = "The name of the Machine Learning Workspace."
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Machine Learning Workspace. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The location/region where the Machine Learning Workspace is created."
}

variable "app_insights_id" {
  type        = string
  description = "The Application Insights resource ID to link to the Machine Learning Workspace."
}

variable "key_vault_id" {
  type        = string
  description = "The Key Vault resource ID to link to the Machine Learning Workspace."
}

variable "storage_account_id" {
  type        = string
  description = "The Storage Account resource ID to link to the Machine Learning Workspace."
}

variable "sku_name" {
    description = "SKU name for the workspace"
    type        = string
    default     = "Basic"
}

variable "vm_priority" {
  description = "The priority of the virtual machines in the cluster. Possible values are: 'Dedicated', 'LowPriority', 'Spot'. Defaults to 'Dedicated'."
  type        = string
  default     = "Dedicated"
}

variable "vm_size" {
  description = "The size of the virtual machines in the cluster. Examples include: 'STANDARD_D2_V3', 'STANDARD_NC6', 'STANDARD_NV6'."
  type        = string
  default     = "STANDARD_D2_V3"
}