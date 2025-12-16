output "boot_diagnostics" {
  value = var.storage_account_deployment_mode == "None" ? false : true
}

output "storage_account_ip_rules" {
  value = local.storage_account_ip_rules
}

output "storage_account_primary_blob_endpoint" {
  value = var.storage_account_deployment_mode == "None" || var.storage_account_deployment_mode == "Managed" ? "" : (
    var.storage_account_deployment_mode == "Existing" ? data.azurerm_storage_account.existing_storage_account[0].primary_blob_endpoint :
    azurerm_storage_account.vm_boot_diagnostics_storage[0].primary_blob_endpoint
  )
}

output "storage_account_type" {
  value = var.storage_account_type
}

output "storage_account_deployment_mode" {
  value = var.storage_account_deployment_mode
}
