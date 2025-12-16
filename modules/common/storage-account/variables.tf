//********************** Basic Configurations **************************//
variable "resource_group_name" {
  description = "Azure Resource Group name to build into."
  type        = string
}

variable "location" {
  description = "The location/region where resources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions."
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the storage account."
  type        = map(string)
  default     = {}
}

//********************** Storage Account Variables **************************//
variable "storage_account_deployment_mode" {
  description = "The deployment mode for the storage account."
  type        = string
  default     = "New"

  validation {
    condition = contains([
      "New",
      "Existing",
      "Managed",
      "None"
    ], var.storage_account_deployment_mode)
    error_message = "The storage_account_deployment_mode variable must be one of 'New', 'Existing', 'Managed' or 'None'."
  }
}

variable "existing_storage_account_name" {
  description = "The name of an existing storage account."
  type        = string
  default     = ""

  validation {
    condition     = var.storage_account_deployment_mode == "Existing" ? var.existing_storage_account_name != "" : true
    error_message = "Variable [existing_storage_account_name] must be set only when 'storage_account_deployment_mode' is set to 'Existing'."
  }
}

variable "existing_storage_account_resource_group_name" {
  description = "The resource group name of an existing storage account."
  type        = string
  default     = ""

  validation {
    condition     = var.storage_account_deployment_mode == "Existing" ? var.existing_storage_account_resource_group_name != "" : true
    error_message = "Variable [existing_storage_account_resource_group_name] must be set only when 'storage_account_deployment_mode' is set to 'Existing'."
  }
}

variable "add_storage_account_ip_rules" {
  description = "Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location."
  type        = bool
  default     = false
}

variable "storage_account_additional_ips" {
  description = "IPs/CIDRs that are allowed access to the Storage Account."
  type        = list(string)
  default     = []

  validation {
    condition = !contains(var.storage_account_additional_ips, "0.0.0.0") && can([for ip in var.storage_account_additional_ips : regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
    ip)])
    error_message = "Variable [storage_account_additional_ips] must be a list of valid IP addresses and cannot contain '0.0.0.0'."
  }
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created."
  type        = string
  default     = "Standard_LRS"

  validation {
    condition = contains([
      "Standard_LRS",
      "Premium_LRS"
    ], var.storage_account_type)
    error_message = "Variable [storage_account_type] must be one of 'Standard_LRS', 'Premium_LRS'."
  }
}

variable "storage_account_tier" {
  description = "Defines the Tier to use for this storage account."
  type        = string
  default     = "Standard"

  validation {
    condition = contains([
      "Standard",
      "Premium"
    ], var.storage_account_tier)
    error_message = "Variable [storage_account_tier] must be one of 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
  default     = "LRS"

  validation {
    condition = contains([
      "LRS",
      "GRS",
      "RAGRS",
      "ZRS"
    ], var.account_replication_type)
    error_message = "Variable [account_replication_type] must be one of 'LRS', 'GRS', 'RAGRS' or 'ZRS'."
  }
}
