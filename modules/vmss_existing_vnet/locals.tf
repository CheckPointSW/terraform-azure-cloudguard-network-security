locals {
  module_name = "vmss_terraform_registry"
  module_version = "1.0.5"

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
}
