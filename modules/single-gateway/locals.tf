locals {
  module_name = "single_terraform_registry"
  module_version = "1.0.9"
  vm_os_sku = var.installation_type == "standalone" ? "mgmt-byol" : var.vm_os_sku
  is_blink = var.installation_type == "gateway"
  template_name  = var.enable_ipv6 ? "single_terraform_registry_dual_stack" : "single_terraform_registry"
}
