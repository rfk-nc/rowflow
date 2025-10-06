
module "private_dns_zones" {
  for_each = local.private_dns_zones_map

  source = "../modules/private-dns-zone"

  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg_private_dns_zones[each.value.region].name
  vnet_id             = module.vnet[each.value.region].vnet.id

  tags = var.tags
}

locals {
  private_dns_zones = var.features.private_dns_zones_enabled ? {
    container_apps              = "azurecontainerapps.io"
    container_registry          = "privatelink.azurecr.io"
    key_vault                   = "privatelink.vaultcore.azure.net"
    postgres_sql                = "privatelink.postgres.database.azure.com"
    storage_blob                = "privatelink.blob.core.windows.net"
    storage_queue               = "privatelink.queue.core.windows.net"
    storage_table               = "privatelink.table.core.windows.net"
    # Following zones are for Application Insights and Log Analytics:
    app_insights                = "privatelink.monitor.azure.com"
    automation                  = "privatelink.agentsvc.azure-automation.net"
    operations_data_store       = "privatelink.ods.opinsights.azure.com"
    operations_management_suite = "privatelink.oms.opinsights.azure.com"
  } : {}

  private_dns_zones_obj_list = flatten([
    for region in keys(var.regions) : [
      for description, zone in local.private_dns_zones : {
        region      = region
        description = description
        name        = zone
      } if zone != null
    ]
  ])
  private_dns_zones_map = { for obj in local.private_dns_zones_obj_list : "${obj.region}-${obj.description}" => obj }
}
