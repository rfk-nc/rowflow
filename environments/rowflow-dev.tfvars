# Basic RowFlow configuration

features = {
  diagnostics_enabled                  = true # Cannot currently be false due to dependencies in other modules
  log_analytics_workspace_enabled      = true # Cannot currently be false due to dependencies in other modules
  private_endpoints_enabled            = false
  private_dns_zones_enabled            = true
  private_service_connection_is_manual = false
  public_network_access_enabled        = true
  vnet_integration_enabled             = true # Cannot currently be false due to dependencies in other modules
}

regions = {
  uksouth = {
    is_primary_region = true
    address_space     = "10.1.0.0/16"
    connect_peering   = false
    subnets = {
      pep = {
        cidr_newbits = 8
        cidr_offset  = 1
        create_nsg   = false
      }
      container-app-default = {
        cidr_newbits               = 7
        cidr_offset                = 1
        create_nsg                 = false
        delegation_name            = "Microsoft.App/environments"
        service_delegation_name    = "Microsoft.App/environments"
        service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

acr = {
  name_suffix                   = "rowflow"
  admin_enabled                 = false
  uai_name                      = "acr"
  sku                           = "Standard"
  public_network_access_enabled = true

}

application_insights = {
  application_insights_type = "web"
}

container_app_environments = {
  instances = {
    default = {
      zone_redundancy_enabled = false
    }
  }
}

cosmosdb = {
  account_name = "rowflowcache"
  databases = {
    rowflow = {
      database_name = "rowflow"
    }
  }
}

key_vault = {
  disk_encryption            = true
  soft_delete_retention_days = 7
  purge_protection           = false
  sku_name                   = "standard"
}

law = {
  law_sku            = "PerGB2018"
  retention_days     = 30
  export_enabled     = false
  export_table_names = ["Alert"]
}

storage_accounts = {
  rowflow = {
    name_suffix                             = "rowflow"
    account_tier                            = "Standard"
    replication_type                        = "LRS"
    public_network_access_enabled           = true
    blob_properties_delete_retention_policy = 7
    blob_properties_versioning_enabled      = false
    containers = {
      ml-container = {
        container_name        = "ml-container"
        container_access_type = "private"
      }
    }
  }
}
