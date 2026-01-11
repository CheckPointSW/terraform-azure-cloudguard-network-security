//************** Basic config variables**************//
variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type        = string
}

variable "resource_group_id" {
  description = "Azure Resource Group ID to use."
  type        = string
  default     = ""
}

variable "location" {
  description = "The location/region where resources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the resource group."
  type        = map(string)
  default     = {}
}

//************** Availability Zones variables **************
variable "is_zonal" {
  description = "Define if resources should be deployed in Availability Zones"
  type        = bool
  default     = false
}

variable "availability_zones_num" {
  description = "Number of availability zones to use. Relevant only if 'is_zonal' is true"
  type        = string
  default     = "0"
}

variable "availability_zones" {
  description = "A list of availability zones to use."
  type        = list(string)
  default     = []
}

//************** Virtual machine instance variables **************
variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  type        = string
  default     = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
  type        = string
}

variable "admin_shell" {
  description = "The admin shell to configure on machine or the first time"
  type        = string
  default     = "/etc/cli.sh"

  validation {
    condition = contains([
      "/etc/cli.sh",
      "/bin/bash",
      "/bin/csh",
      "/bin/tcsh"
    ], var.admin_shell)
    error_message = "Variable [admin_shell] must be one of the following: '/etc/cli.sh', '/bin/bash', '/bin/csh', '/bin/tcsh'."
  }
}

variable "serial_console_password_hash" {
  description = "Optional parameter, used to enable serial console connection in case of SSH key as authentication type"
  type        = string
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type        = string
}

variable "vm_instance_identity_type" {
  description = "Managed Service Identity type"
  type        = string
  default     = "SystemAssigned"
}

variable "module_name" {
  description = "Template name. Should be defined according to deployment type(ha, vmss)"
  type        = string
}

variable "module_version" {
  description = "Template name. Should be defined according to deployment type(e.g. ha, vmss)"
  type        = string
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot"
  type        = string
  default     = ""
}

variable "os_version" {
  description = "GAIA OS version"
  type        = string

  validation {
    condition = contains([
      "R8110",
      "R8120",
      "R82",
      "R8210"
    ], var.os_version)
    error_message = "Variable [os_version] must be one of the following: 'R8110', 'R8120', 'R82', 'R8210'."
  }
}

variable "installation_type" {
  description = "Installation type."
  type        = string

  validation {
    condition = contains([
      "cluster",
      "vmss",
      "management",
      "standalone",
      "gateway",
      "mds-primary",
      "mds-secondary",
      "mds-logserver"
    ], var.installation_type)
    error_message = "Variable [installation_type] must be one of the following: 'cluster', 'vmss', 'management', 'standalone', 'gateway', 'mds-primary', 'mds-secondary', 'mds-logserver'."
  }
}

variable "number_of_vm_instances" {
  description = "Number of VM instances to deploy"
  type        = string
}

variable "allow_upload_download" {
  description = "Allow upload/download to Check Point"
  type        = bool
}

variable "is_blink" {
  description = "Define if blink image is used for deployment"
  type        = bool
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine"
  type        = string

  validation {
    condition = contains(["Standard_F2s", "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_M8ms",
      "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s", "Standard_F2", "Standard_F4",
      "Standard_F8", "Standard_F16", "Standard_D2_v5", "Standard_D4_v5", "Standard_D8_v5", "Standard_D16_v5",
      "Standard_D32_v5", "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5",
      "Standard_D2d_v5", "Standard_D4d_v5", "Standard_D8d_v5", "Standard_D16d_v5", "Standard_D32d_v5",
      "Standard_D2ds_v5", "Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5"
    ], var.vm_size)
    error_message = <<-EOF
      Variable [vm_size] must be one of the allowed VM sizes: 'Standard_F2s', 'Standard_F4s', 'Standard_F8s',
      'Standard_F16s', 'Standard_M8ms', 'Standard_M16ms', 'Standard_M32ms', 'Standard_M64ms', 'Standard_M64s',
      'Standard_F2', 'Standard_F4', 'Standard_F8', 'Standard_F16', 'Standard_D2_v5', 'Standard_D4_v5',
      'Standard_D8_v5', 'Standard_D16_v5', 'Standard_D32_v5', 'Standard_D2s_v5', 'Standard_D4s_v5',
      'Standard_D8s_v5', 'Standard_D16s_v5', 'Standard_D2d_v5', 'Standard_D4d_v5', 'Standard_D8d_v5',
      'Standard_D16d_v5', 'Standard_D32d_v5', 'Standard_D2ds_v5', 'Standard_D4ds_v5', 'Standard_D8ds_v5',
      'Standard_D16ds_v5', 'Standard_D32ds_v5'.
    EOF
  }
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when VM is terminated"
  default     = true
}

variable "publisher" {
  description = "CheckPoint publisher"
  default     = "checkpoint"
}

//************** Storage image reference and plan variables ****************//
variable "vm_os_offer" {
  description = "The name of the image offer to be deployed."
  type        = string

  validation {
    condition = contains([
      "check-point-cg-r8110",
      "check-point-cg-r8120",
      "check-point-cg-r82",
      "check-point-cg-r8210",
    ], var.vm_os_offer)
    error_message = "Variable [vm_os_offer] must be one of the following: 'check-point-cg-r8110', 'check-point-cg-r8120', 'check-point-cg-r82', 'check-point-cg-r8210'."
  }
}

variable "vm_os_sku" {
  description = "The sku of the image to be deployed"
  type        = string

  validation {
    condition = contains([
      "sg-byol",
      "sg-ngtp",
      "sg-ngtx",
      "mgmt-byol",
      "mgmt-25"
    ], var.vm_os_sku)
    error_message = "Variable [vm_os_sku] must be one of the following: 'sg-byol', 'sg-ngtp', 'sg-ngtx', 'mgmt-byol', 'mgmt-25'."
  }
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. "
  type        = string
  default     = "latest"
}

variable "disk_size" {
  description = "Storage data disk size size(GB). Select a number between 100 and 3995"
  type        = string

  validation {
    condition     = can(tonumber(var.disk_size)) && tonumber(var.disk_size) >= 100 && tonumber(var.disk_size) <= 3995
    error_message = "Variable [disk_size] must be a number between 100 and 3995."
  }
}

//************** Storage OS disk variables **************//
variable "storage_os_disk_create_option" {
  description = "The method to use when creating the managed disk"
  type        = string
  default     = "FromImage"
}

variable "storage_os_disk_caching" {
  description = "Specifies the caching requirements for the OS Disk"
  default     = "ReadWrite"
}

variable "managed_disk_type" {
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition = contains([
      "Standard_LRS",
      "Premium_LRS"
    ], var.managed_disk_type)
    error_message = "Variable [managed_disk_type] must be one of the following: 'Standard_LRS', 'Premium_LRS'."
  }
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used"
  type        = string

  validation {
    condition = contains([
      "Password",
      "SSH Public Key"
    ], var.authentication_type)
    error_message = "Variable [authentication_type] must be one of the following: 'Password', 'SSH Public Key'."
  }
}

//********************** Role Assignments variables**************************//
variable "role_definition" {
  description = "Role definition. The full list of Azure Built-in role descriptions can be found at https://docs.microsoft.com/bs-latn-ba/azure/role-based-access-control/built-in-roles"
  type        = string
  default     = "Contributor"
}
