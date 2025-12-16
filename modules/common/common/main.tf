resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.5.1"

  count                     = var.is_zonal ? 1 : 0
  use_cached_data           = false
  enable_telemetry          = false
  availability_zones_filter = true
  recommended_filter        = false
}

resource "null_resource" "validate_region" {
  count = var.is_zonal ? 1 : 0

  lifecycle {
    precondition {
      condition     = contains(keys(module.regions[0].regions_by_name), var.location)
      error_message = "The selected region (${var.location}) does not support Availability Zones. Change to a supported region or set configuration to not use zones"
    }

    postcondition {
      condition     = length(var.availability_zones) == length(distinct(var.availability_zones))
      error_message = "Duplicate zones: ${join(", ", var.availability_zones)}"
    }

    postcondition {
      condition     = length(var.availability_zones) == tonumber(var.availability_zones_num) || length(var.availability_zones) == 0
      error_message = "The number of availability zones in list (${join(", ", var.availability_zones)}) must match the specified number of Availability Zones (${var.availability_zones_num})."
    }

    postcondition {
      condition     = !(!can(regex("^([0-9]+)$", var.availability_zones_num)) || length(module.regions[0].regions_by_name[var.location].zones) < tonumber(var.availability_zones_num))
      error_message = "The value of availability zones must be valid for the current region and a whole number."
    }

    postcondition {
      condition     = length([for zone in var.availability_zones : zone if !contains(module.regions[0].regions_by_name[var.location].zones, tonumber(zone))]) == 0
      error_message = "Invalid zones for region ${var.location}: ${join(", ", var.availability_zones)}"
    }
  }
}
