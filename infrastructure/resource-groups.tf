resource "azurerm_resource_group" "core" {
  for_each = var.regions

  name     = module.regions_config[each.key].names.resource-group
  location = each.key

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_resource_group" "rg_vnet" {
  for_each = var.regions

  name     = "${module.regions_config[each.key].names.resource-group}-networking"
  location = each.key
}

resource "azurerm_resource_group" "rg_private_dns_zones" {
  for_each = var.features.private_dns_zones_enabled ? var.regions : {}

  name     = "${module.regions_config[each.key].names.resource-group}-private-dns-zones"
  location = each.key
}

resource "azurerm_resource_group" "rg_private_endpoints" {
  for_each = var.features.private_endpoints_enabled ? var.regions : {}

  name     = "${module.regions_config[each.key].names.resource-group}-private-endpoints"
  location = each.key
}