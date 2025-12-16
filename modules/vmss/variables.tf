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

variable "vmss_name" {
  description = "VMSS name."
  type        = string
}

variable "location" {
  description = "The location/region where resources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions."
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
  default     = "notused"
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used."
  type        = string
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
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
  default     = ""
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions."
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine."
  type        = string
}

variable "disk_size" {
  description = "Storage data disk size size (GB). Select a number between 100 and 3995."
  type        = string
  default     = "100"

  validation {
    condition     = tonumber(var.disk_size) != 100 && contains(["R8110", "R8120"], var.os_version) ? false : true
    error_message = "Variable [disk_size] cannot be changed if the OS version is R81.20 or below."
  }
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
  description = "The name of the offer of the image that you want to deploy."
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
  default     = "value"
}

variable "availability_zones_num" {
  description = "The number of availability zones to use for Scale Set. Note that the load balancers and their IP addresses will be redundant in any case."
  type        = string
  default     = "0"
}

variable "availability_zones" {
  description = "A list of availability zones to use for Scale Set."
  type        = list(string)
  default     = []
}

variable "is_blink" {
  description = "Define if blink image is used for deployment."
  default     = true
}

variable "configuration_template_name" {
  description = "The configuration template name as it appears in the configuration file."
  type        = string
}

variable "enable_custom_metrics" {
  description = "Enable CloudGuard metrics in order to send statuses and statistics collected from VMSS instances to the Azure Monitor service."
  type        = bool
  default     = true
}

//*********************** Management Variables **************************//
variable "management_name" {
  description = "The name of the management server as it appears in the configuration file."
  type        = string
}

variable "management_IP" {
  description = "The IP address used to manage the VMSS instances."
  type        = string
}

variable "management_interface" {
  description = "Manage the Gateways in the Scale Set via the instance's external (eth0) or internal (eth1) NIC's private IP address."
  type        = string
  default     = "eth1-private"

  validation {
    condition = contains([
      "eth0-public",
      "eth0-private",
      "eth1-private"
    ], var.management_interface)
    error_message = "Variable [management_interface] must be one of the following: 'eth0-public', 'eth0-private', 'eth1-private'."
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
  default     = "10.0.0.0/16"
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
  description = "Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location."
  type        = bool
  default     = false
}

variable "storage_account_additional_ips" {
  description = "IPs/CIDRs that are allowed access to the Storage Account."
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

//********************* Load Balancers Variables **********************//
variable "deployment_mode" {
  description = "The type of the deployment, can be 'Standard' for both load balancers or 'External' for external load balancer or 'Internal for internal load balancer."
  type        = string
  default     = "Standard"

  validation {
    condition = contains([
      "Standard",
      "External",
      "Internal"
    ], var.deployment_mode)
    error_message = "Variable [deployment_mode] must be one of the following: 'Standard', 'External', 'Internal'."
  }
}

variable "backend_lb_IP_address" {
  description = "The IP address is defined by its position in the subnet."
  type        = number
}

variable "lb_probe_port" {
  description = "Port to be used for load balancer health probes and rules."
  type        = string
  default     = "8117"
}

variable "lb_probe_protocol" {
  description = "Protocols to be used for load balancer health probes and rules."
  type        = string
  default     = "Tcp"
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  type        = number
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds load balancer health probe rule performs a check."
  type        = number
  default     = 5
}

variable "frontend_port" {
  description = "Port that will be exposed to the external Load Balancer."
  type        = string
  default     = "80"
}

variable "backend_port" {
  description = "Port that will be exposed to the external Load Balance."
  type        = string
  default     = "80"
}

variable "frontend_load_distribution" {
  description = "Specifies the load balancing distribution type to be used by the frontend load balancer."
  type        = string

  validation {
    condition = contains([
      "Default",
      "SourceIP",
      "SourceIPProtocol"
    ], var.frontend_load_distribution)
    error_message = "Variable [frontend_load_distribution] must be one of the following: 'Default', 'SourceIP', 'SourceIPProtocol'."
  }
}

variable "backend_load_distribution" {
  description = "Specifies the load balancing distribution type to be used by the backend load balancer"
  type        = string

  validation {
    condition = contains([
      "Default",
      "SourceIP",
      "SourceIPProtocol"
    ], var.backend_load_distribution)
    error_message = "Variable [backend_load_distribution] must be one of the following: 'Default', 'SourceIP', 'SourceIPProtocol'."
  }
}

variable "enable_floating_ip" {
  description = "Indicates whether the load balancers will be deployed with floating IP."
  type        = bool
  default     = true
}

variable "use_public_ip_prefix" {
  description = "Indicates whether the public IP resources will be deployed with public IP prefix."
  type        = bool
  default     = false
}

variable "create_public_ip_prefix" {
  description = "Indicates whether the public IP prefix will created or an existing will be used."
  type        = bool
  default     = false
}

variable "existing_public_ip_prefix_id" {
  description = "The existing public IP prefix resource id."
  type        = string
  default     = ""
}

//********************** Scale Set variables *******************//
variable "number_of_vm_instances" {
  description = "Default number of VM instances to deploy."
  type        = string
  default     = "2"
}

variable "minimum_number_of_vm_instances" {
  description = "Minimum number of VM instances to deploy."
  type        = string
}

variable "maximum_number_of_vm_instances" {
  description = "Maximum number of VM instances to deploy."
  type        = string
}

variable "notification_email" {
  description = "Specifies a list of custom email addresses to which the email notifications will be sent."
  type        = string
}
