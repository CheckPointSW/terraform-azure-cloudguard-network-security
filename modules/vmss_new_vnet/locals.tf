locals {
  module_name = "vmss_terraform_registry"
  module_version = "1.0.6"

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
  validate_number_of_vm_instances = local.number_of_vm_instances >= var.minimum_number_of_vm_instances? 0 : index("error: The number of VM instances must be at least ${var.minimum_number_of_vm_instances}.")

  vmss_tags = var.management_interface == "eth0" ? {
    x-chkp-management = var.management_name,
    x-chkp-template = var.configuration_template_name,
    x-chkp-ip-address = local.management_ip_address_type,
    x-chkp-management-interface = local.management_interface_name,
    x-chkp-management-address = var.management_IP,
    x-chkp-topology = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing = "eth0:false,eth1:false",
    x-chkp-srcImageUri = var.source_image_vhd_uri
  } : {
    x-chkp-management = var.management_name,
    x-chkp-template = var.configuration_template_name,
    x-chkp-ip-address = local.management_ip_address_type,
    x-chkp-management-interface = local.management_interface_name,
    x-chkp-topology = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing = "eth0:false,eth1:false",
    x-chkp-srcImageUri = var.source_image_vhd_uri
  }
}
