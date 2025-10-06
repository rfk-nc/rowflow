module "key_vault" {
  for_each = var.key_vault != {} ? var.regions : {}

  source = "../modules/key-vault"

  name                = module.regions_config[each.key].names.key-vault
  resource_group_name = azurerm_resource_group.core[each.key].name
  location            = each.key

  disk_encryption          = var.key_vault.disk_encryption
  soft_delete_retention    = var.key_vault.soft_delete_retention_days
  purge_protection_enabled = var.key_vault.purge_protection
  sku_name                 = var.key_vault.sku_name

  enable_rbac_authorization = true
  rbac_roles                = local.rbac_roles_key_vault_officer

  log_analytics_workspace_id                       = var.features.log_analytics_workspace_enabled ? module.log_analytics_workspace[local.primary_region].id : null
  monitor_diagnostic_setting_keyvault_enabled_logs = var.features.diagnostics_enabled ? local.monitor_diagnostic_setting_keyvault_enabled_logs : null
  monitor_diagnostic_setting_keyvault_metrics      = var.features.diagnostics_enabled ? local.monitor_diagnostic_setting_keyvault_metrics : null
  metric_enabled                                   = var.features.diagnostics_enabled ? true : false

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = var.features.private_endpoints_enabled ? {
    private_dns_zone_ids_keyvault        = module.private_dns_zones["${each.key}-key_vault"].private_dns_zone_ids
    private_endpoint_enabled             = var.features.private_endpoints_enabled
    private_endpoint_subnet_id           = module.subnets["${module.regions_config[each.key].names.subnet}-pep"].id
    private_endpoint_resource_group_name = azurerm_resource_group.rg_private_endpoints[each.key].name
    private_service_connection_is_manual = var.features.private_service_connection_is_manual
  } : null

  tags = var.tags
}
