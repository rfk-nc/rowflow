
resource "azurerm_application_insights" "application_insights" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  workspace_id        = var.log_analytics_workspace_id
  application_type    = var.application_insights_type

  tags = var.tags
}
