//********************** Existing Storage Account **************************//
data "azurerm_storage_account" "existing_storage_account" {
  count               = var.storage_account_deployment_mode == "Existing" ? 1 : 0
  name                = var.existing_storage_account_name
  resource_group_name = var.existing_storage_account_resource_group_name
}

locals {
  // Validate the storage account location matches the resource group location
  validate_location = var.storage_account_deployment_mode == "Existing" ? (
    data.azurerm_storage_account.existing_storage_account[0].location == var.location ? 0 : index("error:", "The storage account must be in the same location as the resource group.")
  ) : 0
}

//********************** New Storage Account **************************//
resource "random_id" "random_id" {
  count = var.storage_account_deployment_mode == "New" ? 1 : 0
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 8
}


resource "azurerm_storage_account" "vm_boot_diagnostics_storage" {
  count                    = var.storage_account_deployment_mode == "New" ? 1 : 0
  name                     = "bootdiag${random_id.random_id[count.index].hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action = var.add_storage_account_ip_rules ? "Deny" : "Allow"
    ip_rules       = local.storage_account_ip_rules
  }

  blob_properties {
    delete_retention_policy {
      days = "15"
    }
  }

  tags = var.tags
}
