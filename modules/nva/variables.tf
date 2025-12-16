//********************** Authentication Variables **************************//
variable "authentication_method" {
  description = "Azure authentication method"
  type        = string
  validation {
    condition = contains(["Azure CLI",
    "Service Principal"], var.authentication_method)
    error_message = "Valid values for authentication_method are 'Azure CLI','Service Principal'"
  }
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "client_id" {
  description = "Application ID(Client ID)"
  type        = string
}

variable "client_secret" {
  description = "A secret string that the application uses to prove its identity when requesting a token. Also can be referred to as application password."
  type        = string
}

//********************** Basic Configurations Variables **************************//
variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "tags" {
  description = "Assign tags by resource."
  type        = map(map(string))
  default     = {}
}

//********************** Virtual WAN Configurations Variables **************************//
variable "vwan_name" {
  description = "The name of the Virtual WAN."
  type        = string
  default     = "tf-vwan"

  validation {
    condition     = var.vwan_hub_address_prefix != "" ? var.vwan_name != "" : true
    error_message = "When creating a new VWAN, you must provide a name for the VWAN."
  }
}

variable "vwan_hub_name" {
  description = "The name of the Virtual Hub."
  type        = string
  default     = "tf-vwan-hub"

  validation {
    condition     = var.vwan_hub_name != ""
    error_message = "You must provide a name for the VWAN hub."
  }
}

variable "vwan_hub_resource_group" {
  description = "The resource group name for the Virtual Hub when using an existing VWAN."
  type        = string
  default     = ""

  validation {
    condition     = var.vwan_hub_address_prefix == "" ? var.vwan_hub_resource_group != "" : true
    error_message = "When using an existing VWAN, you must provide the resource group name of the VWAN hub."
  }
}

variable "vwan_hub_address_prefix" {
  description = "The address prefix for the Virtual Hub."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = var.vwan_hub_address_prefix != "" ? can(cidrhost(var.vwan_hub_address_prefix, 0)) : true
    error_message = "Please provide a valid CIDR specification for the VWAN address space"
  }
}

//********************** Network Virtual Appliance Configurations Variables **************************//
variable "managed_app_name" {
  description = "The name of the managed application."
  type        = string
  default     = "tf-vwan-managed-app"
}

variable "nva_rg_name" {
  description = "The name of the resource group in which to create the Network Virtual Appliance."
  type        = string
  default     = "tf-vwan-nva-rg"
}

variable "nva_name" {
  description = "The name of the Network Virtual Appliance."
  type        = string
  default     = "tf-vwan-nva"
}

variable "os_version" {
  description = "GAIA OS version."
  type        = string
  default     = "R82"

  validation {
    condition = contains([
      "R8110",
      "R8120",
      "R82"
    ], var.os_version)
    error_message = "Variable [os_version] must be one of the following: 'R8110', 'R8120', 'R82'."
  }
}

variable "license_type" {
  description = "License type."
  type        = string
  default     = "Security Enforcement (NGTP)"

  validation {
    condition = contains([
      "Security Enforcement (NGTP)",
      "Full Package (NGTX and Smart-1 Cloud)",
      "Full Package Premium (NGTX and Smart-1 Cloud Premium)"
    ], var.license_type)
    error_message = "Variable [license_type] must be one of the following: 'Security Enforcement (NGTP)', 'Full Package (NGTX and Smart-1 Cloud)', 'Full Package Premium (NGTX and Smart-1 Cloud Premium)'."
  }
}

variable "scale_unit" {
  description = "The scale unit of the CloudGuard Gateway."
  type        = string
  default     = "2"

  validation {
    condition = contains([
      "2",
      "4",
      "10",
      "20",
      "30",
      "60",
      "80"
    ], var.scale_unit)
    error_message = "Variable [scale_unit] must be one of the following: '2', '4', '10', '20', '30', '60', '80'."
  }
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot."
  type        = string
  default     = ""
}

variable "admin_shell" {
  description = "The admin shell to configure on machine or the first time."
  type        = string
  default     = "/etc/cli.sh"

  validation {
    condition = contains([
      "/etc/cli.sh",
      "/bin/bash",
      "/bin/tcsh",
      "/bin/csh"
    ], var.admin_shell)
    error_message = "Variable [admin_shell] must be one of the following: '/etc/cli.sh', '/bin/bash', '/bin/tcsh', '/bin/csh'."
  }
}

variable "sic_key" {
  description = "Secure Internal Communication (SIC) key."
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition = can(regex("^[a-z0-9A-Z]{8,30}$",
    var.sic_key))
    error_message = "Only alphanumeric characters are allowed, and the value must be 8-30 characters long."
  }
}

variable "admin_SSH_key" {
  description = "The SSH public key for SSH authentication to the template instances."
  type        = string
  default     = ""
}

variable "serial_console_password_hash" {
  description = "Serial console connection password hash. In R81.10 and below, the serial console password is also used as the maintenance mode password."
  type        = string
  default     = ""
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions."
  type        = string
  default     = ""
}

variable "bgp_asn" {
  type    = string
  default = "64512"

  validation {
    condition     = tonumber(var.bgp_asn) >= 64512 && tonumber(var.bgp_asn) <= 65534 && !contains([65515, 65520], tonumber(var.bgp_asn))
    error_message = "Variable [bgp_asn] must be in the range 64512-65534, excluding 65515 and 65520."
  }
}

variable "custom_metrics" {
  description = "Enable/Disable custom metrics on the CloudGuard Gateway."
  type        = string
  default     = "yes"

  validation {
    condition = contains([
      "yes",
      "no"
    ], var.custom_metrics)
    error_message = "Variable [custom_metrics] must be either 'yes' or 'no'."
  }
}

//********************** Networking Configurations **************************//
variable "routing_intent_internet_traffic" {
  description = "Enable/Disable routing intent for internet traffic."
  type        = string
  default     = "yes"

  validation {
    condition = contains([
      "yes",
      "no"
    ], var.routing_intent_internet_traffic)
    error_message = "Variable [routing_intent_internet_traffic] must be either 'yes' or 'no'."
  }
}

variable "routing_intent_private_traffic" {
  description = "Enable/Disable routing intent for private traffic."
  type        = string
  default     = "yes"

  validation {
    condition = contains([
      "yes",
      "no"
    ], var.routing_intent_private_traffic)
    error_message = "Variable [routing_intent_private_traffic] must be either 'yes' or 'no'."
  }
}

variable "existing_public_ip" {
  description = "The ID of an existing public IP to be used for the CloudGuard Gateway."
  type        = string
  default     = ""
}

variable "new_public_ip" {
  description = "Create a new public IP for the CloudGuard Gateway."
  type        = string
  default     = "no"

  validation {
    condition = contains([
      "yes",
      "no"
    ], var.new_public_ip)
    error_message = "Variable [new_public_ip] must be either 'yes' or 'no'."
  }

  validation {
    condition     = var.existing_public_ip != "" && var.new_public_ip == "no" ? true : var.existing_public_ip == "" && var.new_public_ip == "yes"
    error_message = "To assign a public IP to the CloudGuard Gateway, you must either provide an existing public IP or set new_public_ip to 'yes' to create a new one."
  }
}

//********************** Smart-1 Cloud Configurations Variables **************************//
variable "smart1_cloud_token_a" {
  description = "Smart-1 Cloud Token, for configuring member A."
  type        = string
  default     = ""
}

variable "smart1_cloud_token_b" {
  description = "Smart-1 Cloud Token, for configuring member B."
  type        = string
  default     = ""
}

variable "smart1_cloud_token_c" {
  description = "Smart-1 Cloud Token, for configuring member C."
  type        = string
  default     = ""
}

variable "smart1_cloud_token_d" {
  description = "Smart-1 Cloud Token, for configuring member D."
  type        = string
  default     = ""
}

variable "smart1_cloud_token_e" {
  description = "Smart-1 Cloud Token, for configuring member E."
  type        = string
  default     = ""
}

//********************** Marketplace Plan Configurations Variables **************************//
variable "plan_product" {
  description = "Use the following plan when deploying with terraform: cp-vwan-managed-app."
  type        = string
  default     = "cp-vwan-managed-app"
}

variable "plan_version" {
  description = "Use the latest version of the managed application (e.g., 1.0.24) for best results. Full version list: https://support.checkpoint.com/results/sk/sk132192."
  type        = string
  default     = "1.0.24"
}

variable "custom_license_type" {
  description = "License type when using staged image."
  type        = string
  default     = ""

  validation {
    condition = contains([
      "",
      "ngtp",
      "ngtx",
      "premium"
    ], var.custom_license_type)
    error_message = "Valid options are 'ngtp', 'ngtx', or 'premium' or empty."
  }
}
