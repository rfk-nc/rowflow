variable "name" {
  description = "Is the App Insights workspace name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,253}[a-zA-Z0-9]$", var.name))
    error_message = "The App Insights workspace name must be between 1 and 255 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, periods, and underscores (but not at the start or end)."
  }
}

variable "location" {
  type        = string
  description = "The location/region where the AI is created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Application Insights resource. Changing this forces a new resource to be created."
}

variable "application_insights_type" {
  type        = string
  description = "Type of Application Insights (default: web)."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Is the LAW workspace ID in Audit subscription."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}
