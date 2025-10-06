resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  application_insights_id = var.app_insights_id
  key_vault_id            = var.key_vault_id
  storage_account_id      = var.storage_account_id
  sku_name                = var.sku_name

  identity {
    type = "SystemAssigned"
  }
}

# Ideally we would not include this in the same module as the workspace but for simplicity we are doing so here
resource "azurerm_machine_learning_compute_cluster" "ml_cluster" {
  name                          = "${var.name}-cluster"
  location                      = var.location
  vm_priority                   = var.vm_priority
  vm_size                       = var.vm_size
  machine_learning_workspace_id = azurerm_machine_learning_workspace.ml_workspace.id

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 2
    scale_down_nodes_after_idle_duration = "PT30M"
  }
}
