locals {
  module_name    = "high_availability_terraform_registry"
  module_version = "1.0.9"
  extended_zone_region_map = {
    "losangeles" = ["westus"]
    "perth"      = ["australiaeast"]
  }

  # Determine if Availability Set should be created
  availability_set_condition = var.availability_type == "Availability Set" && var.extended_zone == "None"

  # Extended zone configuration
  edge_zone                       = var.extended_zone != "None" ? var.extended_zone : null
  storage_account_deployment_mode = var.extended_zone == "None" ? var.storage_account_deployment_mode : "None"
}
