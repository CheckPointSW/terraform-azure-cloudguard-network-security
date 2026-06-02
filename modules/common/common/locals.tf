locals {
  resource_group = var.resource_group_create
    ? azurerm_resource_group.resource_group[0]
    : data.azurerm_resource_group.resource_group[0]
}
