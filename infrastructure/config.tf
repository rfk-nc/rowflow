
module "regions_config" {
  for_each = var.regions

  source = "../modules/shared-config"

  location    = each.key
  application = var.application
  env         = var.environment
  tags        = var.tags
}
