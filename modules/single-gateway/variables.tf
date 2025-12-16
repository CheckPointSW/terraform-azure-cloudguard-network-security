//********************** Basic Configuration Variables **************************//
variable "subscription_id" {
  description = "Subscription ID"
  type = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type = string
}

variable "client_id" {
  description = "Application ID(Client ID)"
  type = string
}

variable "client_secret" {
  description = "A secret string that the application uses to prove its identity when requesting a token. Also can be referred to as application password."
  type = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name to build into."
  type        = string
}

variable "single_gateway_name" {
  description = "Single Gateway name."
  type        = string
}

variable "location" {
  description = "The location/region where resource will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions."
  type        = string
}

variable "tags" {
  description = "Assign tags by resource."
  type        = map(map(string))
  default     = {}
}

//********************** Virtual Machine Instances Variables **************************//
variable "source_image_vhd_uri" {
  description = "The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images."
  type        = string
  default     = "noCustomUri"
}

variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used."
  type        = string
  default     = "notused"
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used."
  type        = string
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure."
  type        = string
}

variable "admin_SSH_key" {
  description = "(Optional) The SSH public key for SSH authentication to the template instances."
  type        = string
  default     = ""
}

variable "sic_key" {
  description = "Secure Internal Communication (SIC) key."
  type        = string

  validation {
    condition     = length(var.sic_key) >= 12
    error_message = "Variable [sic_key] must be at least 12 characters long."
  }
}

variable "serial_console_password_hash" {
  description = "Optional parameter, used to enable serial console connection in case of SSH key as authentication type."
  type        = string
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions."
  type        = string
}

variable "installation_type" {
  description = "Installation type."
  type        = string
  default     = "gateway"

  validation {
    condition = contains([
      "gateway",
      "standalone"
    ], var.installation_type)
    error_message = "Variable [installation_type] must be one of the following: 'gateway', 'standalone'."
  }
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine."
  type        = string
}

variable "disk_size" {
  description = "Storage data disk size size(GB). Select a number between 100 and 3995."
  type        = string
}

variable "os_version" {
  description = "GAIA OS version."
  type        = string
}

variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type        = string
}

variable "vm_os_offer" {
  description = "The name of the image offer to be deployed."
  type        = string
}

variable "allow_upload_download" {
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point."
  type        = bool
}

variable "admin_shell" {
  description = "The admin shell to configure on machine or the first time."
  type        = string
  default     = "/etc/cli.sh"
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot."
  type        = string
  default     = ""
}

variable "is_blink" {
  description = "Define if blink image is used for deployment."
  default     = true
}


variable "enable_custom_metrics" {
  description = "Indicates whether CloudGuard Metrics will be use for Cluster members monitoring."
  type        = bool
  default     = true
}

variable "zone" {
  description = "The availability zone to use for the Virtual Machine. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

//********************** Smart-1 Cloud Variables **************************//
variable "smart_1_cloud_token" {
  description = "Smart-1 Cloud Token."
  type        = string
}

//********************** Management Variables **************************//
variable "management_GUI_client_network" {
  description = "Allowed GUI clients - GUI clients network CIDR."
  type        = string

  validation {
    condition     = can(regex("(^0\\.0\\.0\\.0\\/0$)|(^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/32)?$)", var.management_GUI_client_network)) && var.management_GUI_client_network != "0.0.0.0/32"
    error_message = "Variable [management_GUI_client_network] must be a valid IPv4 network CIDR."
  }
}

//********************** Networking Variables **************************//
variable "vnet_name" {
  description = "Virtual Network name."
  type        = string
}

variable "existing_vnet_resource_group" {
  description = "The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network."
  type        = string
  default     = ""
}

variable "frontend_subnet_name" {
  description = "The Virtual Network subnet name for the frontend interface."
  type        = string
}

variable "backend_subnet_name" {
  description = "The Virtual Network subnet name for the backend interface."
  type        = string
}

variable "address_space" {
  description = "The address space that is used by a Virtual Network."
  type        = string
  default     = "10.12.0.0/16"
}

variable "subnet_prefixes" {
  description = "Address prefix to be used for network subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "nsg_id" {
  description = "(Optional) The Network Security Group ID."
  type        = string
  default     = ""
}

variable "storage_account_deployment_mode" {
  description = "The deployment mode for the storage account. Options are 'New', 'Existing', 'Managed' and 'None'. If 'Existing', the storage account must be specified in the variable 'existing_storage_account_id'."
  type        = string
  default     = "New"
}

variable "add_storage_account_ip_rules" {
  description = "Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location"
  type        = bool
  default     = false
}

variable "storage_account_additional_ips" {
  description = "IPs/CIDRs that are allowed access to the Storage Account"
  type        = list(string)
  default     = []
}

variable "existing_storage_account_name" {
  description = "The name of an existing storage account to use if 'storage_account_deployment_mode' is set to 'Existing'."
  type        = string
  default     = ""
}

variable "existing_storage_account_resource_group_name" {
  description = "The resource group name of an existing storage account to use if 'storage_account_deployment_mode' is set to 'Existing'."
  type        = string
  default     = ""
}

variable "sku" {
  description = "SKU"
  type        = string
  default     = "Standard"
}

variable "security_rules" {
  description = "Security rules for the Network Security Group using this format [name, priority, direction, access, protocol, source_source_port_rangesport_range, destination_port_ranges, source_address_prefix, destination_address_prefix, description]."
  type        = list(any)
  default = [
    {
      name                       = "AllowAllInBound"
      priority                   = "100"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_ranges         = "*"
      destination_port_ranges    = "*"
      description                = "Allow all inbound connections"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
