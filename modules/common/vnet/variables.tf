//********************** Basic Configurations **************************//
variable "resource_group_name" {
  description = "Azure Resource Group name to build into."
  type        = string
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions."
  type        = string
}

variable "tags" {
  description = "Tags to be associated with Virtual Network and subnets"
  type        = map(map(string))
  default     = {}
}

//********************** Virtual Network Variables **************************//
variable "vnet_name" {
  description = "Name of Virtual Network."
  type        = string
  default     = "vnet01"
}


// The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network.
variable "existing_vnet_resource_group" {
  description = "The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network."
  type        = string
  default     = ""

  validation {
    condition     = local.create_new_vnet || (!local.create_new_vnet && var.existing_vnet_resource_group != "")
    error_message = "Variable [existing_vnet_resource_group] must be provided when using an existing Virtual Network."
  }
}

variable "subnet_names" {
  description = "A list of subnet names in a Virtual Network"
  type        = list(string)
  default     = ["Frontend", "Backend"]

  validation {
    condition     = length(var.subnet_names) <= 2 && length(var.subnet_names) >= 1
    error_message = "At least one subnet is required and a maximum of two subnets are supported."
  }
}

variable "address_space" {
  description = "The address prefixes of the virtual network."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = var.address_space != "" ? can(regex(local.regex_valid_network_cidr, var.address_space)) : true
    error_message = "Variable [address_space] must be a valid address in CIDR notation."
  }
}

variable "subnet_prefixes" {
  description = "The address prefixes to be used for subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]

  validation {
    condition     = local.create_new_vnet ? length(var.subnet_names) == length(var.subnet_prefixes) : true
    error_message = "The length of [subnet_names] and [subnet_prefixes] must be the same."
  }

  validation {
    condition     = local.create_new_vnet ? alltrue([for prefix in var.subnet_prefixes : can(regex(local.regex_valid_network_cidr, prefix))]) : true
    error_message = "All values in [subnet_prefixes] must be valid addresses in CIDR notation."
  }
}

variable "nsg_id" {
  description = "Network security group to be associated with a Virtual Network and subnets"
  type        = string
}

variable "dns_servers" {
  description = " DNS servers to be used with a Virtual Network. If no values specified, this defaults to Azure DNS."
  type        = list(string)
  default     = []
}

variable "allocation_method" {
  description = "IP address allocation method."
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static"], var.allocation_method)
    error_message = "Variable [allocation_method] must be 'Static'."
  }
}
