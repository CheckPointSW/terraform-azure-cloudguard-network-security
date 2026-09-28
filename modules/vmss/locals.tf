locals {
  module_name    = "vmss_terraform_registry"
  module_version = "1.0.9"
  template_name  = "vmss_terraform_registry${var.enable_ipv6 ? "_dual_stack" : ""}${local.is_flexible ? "_flex" : ""}"

  create_frontend_lb = contains(["Standard", "External"], var.deployment_mode)
  create_backend_lb  = contains(["Standard", "Internal"], var.deployment_mode)

  // Validate that the minimum number of VM instances is at least 0.
  // If not, return an error message.
  validate_number_of_vm_instances_range = var.minimum_number_of_vm_instances >= 0 && var.maximum_number_of_vm_instances >= 0 ? 0 : index("error: The minimum and maximum number of VM instances must be at least 0.")

  // Validate that the maximum number of VM instances is greater than or equal to the minimum number of VM instances.
  // If not, return an error message.
  validate_maximum_number_of_vm_instances = var.maximum_number_of_vm_instances >= var.minimum_number_of_vm_instances ? 0 : index("error: The maximum number of VM instances must be greater than or equal to the minimum number of VM instances.")

  // The number of VM instances should not exceed the maximum allowed.
  // If the provided number of instances exceeds the maximum, use the maximum instead.
  number_of_vm_instances = var.maximum_number_of_vm_instances >= var.number_of_vm_instances ? var.number_of_vm_instances : var.maximum_number_of_vm_instances

  // Validate the number of VM instances against the minimum requirement.
  // If the number of instances is less than the minimum, return an error message.
  validate_number_of_vm_instances = local.number_of_vm_instances >= var.minimum_number_of_vm_instances ? 0 : index("error: The number of VM instances must be at least ${var.minimum_number_of_vm_instances}.")

  management_interface_name  = split("-", var.management_interface)[0]
  management_ip_address_type = split("-", var.management_interface)[1]

  is_flexible = var.orchestration_mode == "Flexible"

  vmss_id = local.is_flexible ? (
    azurerm_orchestrated_virtual_machine_scale_set.vmss_flex[0].id
  ) : azurerm_linux_virtual_machine_scale_set.vmss[0].id

  vmss_name = local.is_flexible ? (
    azurerm_orchestrated_virtual_machine_scale_set.vmss_flex[0].name
  ) : azurerm_linux_virtual_machine_scale_set.vmss[0].name

  vmss_principal_id = local.is_flexible ? "" : lookup(azurerm_linux_virtual_machine_scale_set.vmss[0].identity[0], "principal_id")

  vmss_zones = var.availability_zones_num == "0" ? null : (
    length(var.availability_zones) == 0 ? [for i in range(1, tonumber(var.availability_zones_num) + 1) : tostring(i)] : var.availability_zones
  )

  // Custom metrics is forced off on Flexible (SystemAssigned identity unsupported there).
  vmss_custom_data = base64encode(templatefile("${path.module}/cloud-init.sh", {
    installation_type              = module.common.installation_type
    allow_upload_download          = module.common.allow_upload_download
    os_version                     = module.common.os_version
    template_name                  = local.template_name
    module_version                 = module.common.module_version
    template_type                  = "terraform"
    is_blink                       = module.common.is_blink
    bootstrap_script64             = base64encode(var.bootstrap_script)
    location                       = module.common.resource_group_location
    sic_key                        = var.sic_key
    vnet                           = module.vnet.subnet_prefixes[0]
    enable_custom_metrics          = (var.enable_custom_metrics && !local.is_flexible) ? "yes" : "no"
    admin_shell                    = var.admin_shell
    serial_console_password_hash   = var.serial_console_password_hash
    maintenance_mode_password_hash = var.maintenance_mode_password_hash
    set_health_probe               = var.set_static_health_probe
  }))

  vmss_base_tags = var.management_interface == "eth0" ? {
    x-chkp-management           = var.management_name,
    x-chkp-template             = var.configuration_template_name,
    x-chkp-ip-address           = local.management_ip_address_type,
    x-chkp-management-interface = local.management_interface_name,
    x-chkp-management-address   = var.management_IP,
    x-chkp-topology             = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing        = "eth0:false,eth1:false",
    x-chkp-srcImageUri          = var.source_image_vhd_uri,
    x-chkp-ip-version           = var.enable_ipv6 ? "dual-stack" : "ipv4-only"
    } : {
    x-chkp-management           = var.management_name,
    x-chkp-template             = var.configuration_template_name,
    x-chkp-ip-address           = local.management_ip_address_type,
    x-chkp-management-interface = local.management_interface_name,
    x-chkp-topology             = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing        = "eth0:false,eth1:false",
    x-chkp-srcImageUri          = var.source_image_vhd_uri,
    x-chkp-ip-version           = var.enable_ipv6 ? "dual-stack" : "ipv4-only"
  }

  // x-chkp-orchestration-mode is CME's Flexible-detection signal; CME falls
  // back to Uniform for any value other than "Flexible" (including absent).
  vmss_tags = merge(local.vmss_base_tags, {
    x-chkp-orchestration-mode = local.is_flexible ? "Flexible" : "Uniform"
  })
}
