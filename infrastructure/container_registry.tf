module "acr" {
  # only create in regions where is_primary_region is true and only when acr map is not empty
  count = length(var.acr) > 0 ? 1 : 0
  
  source = "../modules/container-registry"

  name                = "${module.regions_config[local.primary_region].names.azure-container-registry}"
  #name                = "${module.regions_config[local.primary_region].names.azure-container-registry}${var.acr.name_suffix}"
  resource_group_name = azurerm_resource_group.core[local.primary_region].name
  location            = local.primary_region

  admin_enabled = var.acr.admin_enabled

  log_analytics_workspace_id                  = var.features.log_analytics_workspace_enabled ? module.log_analytics_workspace[local.primary_region].id : null
  monitor_diagnostic_setting_acr_enabled_logs = var.features.diagnostics_enabled ? local.monitor_diagnostic_setting_acr_enabled_logs : null
  monitor_diagnostic_setting_acr_metrics      = var.features.diagnostics_enabled ? local.monitor_diagnostic_setting_acr_metrics : null

  uai_name                      = "${module.regions_config[local.primary_region].names.user-assigned-identity}-${var.acr.uai_name}"
  sku                           = var.acr.sku
  public_network_access_enabled = var.features.public_network_access_enabled

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = null

  # private_endpoint_properties = var.features.private_endpoints_enabled ? {
  #   private_dns_zone_ids                 = [module.private_dns_zones["${var.acr.region}-container_registry"].id]
  #   private_endpoint_enabled             = var.features.private_endpoints_enabled
  #   private_endpoint_subnet_id           = module.subnets_hub["${module.config[var.acr.region].names.subnet}-acr"].id
  #   private_endpoint_resource_group_name = azurerm_resource_group.rg_project[var.acr.project_key].name
  #   private_service_connection_is_manual = var.features.private_service_connection_is_manual
  # } : null

  tags = {}
}