variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "application" {
  description = "Environment code for deployments"
  type        = string
}

variable "environment" {
  description = "Environment code for deployments"
  type        = string
}

variable "features" {
  description = "Feature flags for the deployment"
  type        = map(bool)
}

variable "regions" {
  type = map(object({
    address_space     = optional(string)
    is_primary_region = bool
    connect_peering   = optional(bool, false)
    subnets = optional(map(object({
      cidr_newbits               = string
      cidr_offset                = string
      create_nsg                 = optional(bool, true) # defaults to true
      name                       = optional(string)     # Optional name override
      delegation_name            = optional(string)
      service_delegation_name    = optional(string)
      service_delegation_actions = optional(list(string))
    })))
  }))
}

variable "acr" {
  description = "Configuration for the Azure Container Registry"
  default     = null
  type = object({
    name_suffix                   = string
    admin_enabled                 = optional(bool, false)
    uai_name                      = optional(string)
    sku                           = optional(string, "Premium")
    public_network_access_enabled = optional(bool, false)
  })
}

variable "application_insights" {
  description = "Configuration of the App Insights"
  type = object({
    application_insights_type = optional(string, "web")
  })
}

variable "container_app_environments" {
  description = "Configuration for the container app environments"
  default     = {}
  type = object({
    instances = optional(map(object({
      workload_profile = optional(object({
        name                  = optional(string, "Consumption")
        workload_profile_type = optional(string, "Consumption")
        minimum_count         = optional(number, 0)
        maximum_count         = optional(string, 0)
      }), {})
      zone_redundancy_enabled = optional(bool, false)
    })), {})
  })
}

variable "container_apps" {
  description = "Configuration for the container app jobs"
  default     = {}
  type = object({
    apps = optional(map(object({
      name_suffix                   = optional(string)
      container_app_environment_key = optional(string)
      docker_env_tag                = optional(string)
      docker_image                  = optional(string)
      is_web_app                    = optional(bool, false)
      container_registry_use_mi     = optional(bool, false)
    })), {})
  })
}

variable "cosmosdb" {
  description = "Configuration for the Cosmos DB account and SQL database"
  default     = {}
  type = object({
    account_name              = optional(string)
    kind                      = optional(string, "GlobalDocumentDB")
    sku_name                  = optional(string, "Standard")
    max_throughput            = optional(number, 2000)
    enable_automatic_failover = optional(bool, false)
    consistency_level         = optional(string, "BoundedStaleness")
    max_interval_in_seconds   = optional(number, 300)
    max_staleness_prefix      = optional(number, 100000)
    databases = optional(map(object({
      database_name  = optional(string)
      max_throughput = optional(number, 1000)
    })), {})
  })
}

variable "key_vault" {
  description = "Configuration for the key vault"
  default     = {}
  type = object({
    disk_encryption            = optional(bool, true)
    soft_delete_retention_days = optional(number, 7)
    purge_protection           = optional(bool, false)
    sku_name                   = optional(string, "standard")
  })
}

variable "law" {
  description = "Configuration of the Log Analytics Workspace"
  default     = {}
  type = object({
    law_sku            = optional(string, "PerGB2018")
    retention_days     = optional(number, 30)
    export_enabled     = optional(bool, false)
    export_table_names = optional(list(string), [])
  })
}

variable "network_security_group_rules" {
  description = "The network security group rules."
  default     = {}
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
}

variable "postgresql" {
  description = "Configuration for the Azure Postgres server instance and a default database "
  default     = {}
  type = object({

    postgres_sql_admin_group      = optional(string)
    backup_retention_days         = optional(number, 7)
    geo_redundant_backup_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, false)
    server_version                = optional(string, "16")
    zone                          = optional(string, "1")

    # Database
    dbs = optional(map(object({
      db_name_suffix = optional(string)
      sku_name       = optional(string, "S0")
      storage_mb     = optional(number, 100)
      storage_tier   = optional(string, "P4")
    })), {})

    # FW Rules
    fw_rules = optional(map(object({
      fw_rule_name = string
      start_ip     = string
      end_ip       = string
    })), {})
  })
}

variable "storage_accounts" {
  description = "Configuration for the Storage Account, currently used for SQL Server audit logs"
  default     = {}
  type = map(object({
    name_suffix                             = string
    account_tier                            = optional(string, "Standard")
    blob_properties_delete_retention_policy = optional(number, 7)
    blob_properties_versioning_enabled      = optional(bool, false)
    replication_type                        = optional(string, "LRS")
    public_network_access_enabled           = optional(bool, false)
    containers = optional(map(object({
      container_name        = string
      container_access_type = optional(string, "private")
    })), {})
  }))
}

variable "tags" {
  description = "Default tags to be applied to resources"
  type        = map(string)
  default     = {}
}
