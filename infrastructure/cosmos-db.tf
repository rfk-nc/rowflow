resource "azurerm_cosmosdb_account" "this" {
  for_each = var.cosmosdb != {} ? var.regions : {}

  name                = "${var.cosmosdb.account_name}${each.key}${var.environment}"
  resource_group_name = azurerm_resource_group.core[each.key].name
  location            = each.key

  kind       = var.cosmosdb.kind
  offer_type = var.cosmosdb.sku_name

  capacity {
    total_throughput_limit = var.cosmosdb.max_throughput
  }
  consistency_policy {
    consistency_level       = var.cosmosdb.consistency_level
    max_interval_in_seconds = var.cosmosdb.max_interval_in_seconds
    max_staleness_prefix    = var.cosmosdb.max_staleness_prefix
  }
  geo_location {
    location          = each.key
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  for_each = var.cosmosdb.databases != {} ? local.database_map : {}

  name                = each.value.database_name
  resource_group_name = azurerm_resource_group.core[each.value.region].name
  account_name        = azurerm_cosmosdb_account.this[each.value.region].name

  autoscale_settings {
    max_throughput = each.value.max_throughput
  }
}

locals {
  # There are multiple App Service Plans and possibly multiple regions.
  # We cannot nest for loops inside a map, so first iterate all permutations of both as a list of objects...
  database_object_list = flatten([
    for region in keys(var.regions) : [
      for database, config in var.cosmosdb.databases : merge(
        {
          region  = region
          database = database
        },
        config
      )
    ]
  ])

  # ...then project the list of objects into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  database_map = {
    for object in local.database_object_list : "${object.database}-${object.region}" => object
  }
}