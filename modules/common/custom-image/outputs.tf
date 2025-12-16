output "id" {
  value = local.custom_image_condition ? azurerm_image.custom_image[0].id : null
}

output "create_custom_image" {
  value = local.custom_image_condition
}
