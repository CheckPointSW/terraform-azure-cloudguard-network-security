locals {
  module_name = "single_terraform_registry"
  module_version = "1.0.9"
  vm_os_sku = var.installation_type == "standalone" ? "mgmt-byol" : var.vm_os_sku
}
