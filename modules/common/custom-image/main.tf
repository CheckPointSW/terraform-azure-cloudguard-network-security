resource "azurerm_image" "custom_image" {
  count               = local.custom_image_condition ? 1 : 0
  name                = "custom-image"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.source_image_vhd_uri
  }

  tags = var.tags
}
