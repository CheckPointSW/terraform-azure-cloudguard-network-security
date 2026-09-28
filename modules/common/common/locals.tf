locals {
  resource_group_name     = var.create_resource_group ? azurerm_resource_group.resource_group[0].name : reverse(split("/", var.resource_group_id))[0]
  resource_group_id       = var.create_resource_group ? azurerm_resource_group.resource_group[0].id : var.resource_group_id
  resource_group_location = var.create_resource_group ? azurerm_resource_group.resource_group[0].location : var.location

  # Effective VM OS disk type. When the caller does not specify one, it defaults to Standard SSD.
  os_disk_type = coalesce(var.os_disk_type, "StandardSSD_LRS")
}
