module "application_insights" {

  for_each = { for key, val in var.regions : key => val if val.is_primary_region }

  source = "../modules/application-insights"

  name                = module.regions_config[each.key].names.application-insights
  resource_group_name = azurerm_resource_group.core[each.key].name
  location            = each.key

  application_insights_type  = var.application_insights.application_insights_type
  log_analytics_workspace_id = module.log_analytics_workspace[each.key].id
  tags                       = var.tags

}
