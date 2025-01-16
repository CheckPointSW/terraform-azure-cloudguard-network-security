# Check Point CloudGuard VMSS Module - New VNet

This Terraform module deploys Check Point CloudGuard VMSS solution into a new VNet in azure.
As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- Role assignment - conditional creation


For additional information,
please see the [CloudGuard Network for Azure Virtual Machine Scale Sets (VMSS) Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_VMSS_for_Azure/Default.htm) 

This solution uses the following modules:
- common - used for creating a resource group and defining common variables.
- vnet - used for creating new virtual network and subnets.
- network_security_group - used for creating new network security groups and rules.


## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest).

**Example:**
```
provider "azurerm" {
  features {}
}

module "example_module" {

    source  = "CheckPointSW/cloudguard-network-security/azure//modules/vmss_new_vnet"
    version = "1.0.2"

    subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    source_image_vhd_uri            = "noCustomUri"
    resource_group_name             = "checkpoint-vmss-terraform"
    location                        = "eastus"
    vmss_name                       = "checkpoint-vmss-terraform"
    vnet_name                       = "checkpoint-vmss-vnet"
    address_space                   = "10.0.0.0/16"
    subnet_prefixes                 = ["10.0.1.0/24","10.0.2.0/24"]
    backend_lb_IP_address           = 4
    admin_password                  = "xxxxxxxxxxxx"
    sic_key                         = "xxxxxxxxxxxx"
    vm_size                         = "Standard_D3_v2"
    disk_size                       = "100"
    vm_os_sku                       = "sg-byol"
    vm_os_offer                     = "check-point-cg-r8110"
    os_version                      = "R8110"
    bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
    allow_upload_download           = true
    authentication_type             = "Password"
    availability_zones_num          = "1"
    minimum_number_of_vm_instances  = 2
    maximum_number_of_vm_instances  = 10
    management_name                 = "mgmt"
    management_IP                   = "13.92.42.181"
    management_interface            = "eth1-private"
    configuration_template_name     = "vmss_template"
    notification_email              = ""
    frontend_load_distribution      = "Default"
    backend_load_distribution       = "Default"
    enable_custom_metrics           = true
    enable_floating_ip              = false
    deployment_mode                 = "Standard"
    admin_shell                     = "/etc/cli.sh"
    serial_console_password_hash    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    maintenance_mode_password_hash  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    nsg_id                          = ""
    add_storage_account_ip_rules    = false
    storage_account_additional_ips  = []
}
```

## Conditional creation
To create role assignment and enable CloudGuard metrics in order to send statuses and statistics collected from VMSS instances to the Azure Monitor service:
```
enable_custom_metrics = true
```

## Deploy Without Public IP

1. By default, the VMSS is deployed with public IP
2. To deploy without public IP, remove the "public_ip_address_configuration" block in main.tf
### Module's variables:
| Name                                  | Description                                                                                                                                                             | Type           | Allowed values                                                                                                                                                                                                                                      |
|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **subscription_id**                   | The subscription ID is used to pay for Azure cloud services                                                                                                             | string         |                                                                                                                                                                                                                                        |
| **source_image_vhd_uri**              | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images                                                      | string         | **Default:** "noCustomUri"                                                                                                                                                                                                                            |
| **resource_group_name**               | The name of the resource group that will contain the contents of the deployment                                                                                         | string         | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period.<br />Note: Resource group name must not contain reserved words based on: sk40179<br />                |
| **location**                          | The region where the resources will be deployed at                                                                                                                      | string         | The full list of Azure regions can be found at https://azure.microsoft.com/regions<br />                                                                                                       |
| **vmss_name**                         | The name of the Check Point VMSS Object                                                                                                                                 | string         | Only alphanumeric characters are allowed, and the name must be 1-30 characters long.<br />Note: VMSS name must not contain reserved words based on: sk40179<br />                                                                      |
| **vnet_name**                         | The name of the virtual network that will be created                                                                                                                    | string         | The name must begin with a letter or number, end with a letter, number, or underscore, and may contain only letters, numbers, underscores, periods, or hyphens<br />                                                                    |
| **address_space**                     | The address prefixes of the virtual network                                                                                                                             | string         | Valid CIDR block<br />**Default:** "10.0.0.0/16"                                                                                                                                                                                                     |
| **subnet_prefixes**                   | The address prefixes to be used for created subnets                                                                                                                     | string         | The subnets need to be contained within the address space for this virtual network (defined by the address_space variable)<br />**Default:** ["10.0.0.0/24", "10.0.1.0/24"]                                                                           |
| **backend_lb_IP_address**             | A whole number that can be represented as a binary integer with no more than the number of digits remaining in the address after the given prefix                        | number         | Starting from the 5th IP address in a subnet. For example: subnet - 10.0.1.0/24, backend_lb_IP_address = 4, the LB IP is 10.0.1.4<br />                                                                                              |
| **admin_password**                    | The password associated with the local administrator account on each cluster member                                                                                     | string         | Password must have 3 of the following: 1 lowercase character, 1 uppercase character, 1 number, and 1 special character<br />                                                                  |
| **sic_key**                           | The Secure Internal Communication one-time secret used to set up trust between the cluster object and the management server                                             | string         | Only alphanumeric characters are allowed, and the value must be 12-30 characters long<br />                                                                                                   |
| **vm_size**                           | Specifies the size of Virtual Machine                                                                                                                                   | string         | A list of valid VM sizes, e.g., "Standard_DS2_v2", "Standard_D4s_v3", "Standard_D64s_v3", etc.<br />                                                                                          |
| **disk_size**                         | Storage data disk size (GB) must be 100 for versions R81.20 and below                                                                                                   | string         | A number in the range 100 - 3995 (GB)<br />**Default:** 100                                                                                                                                                                                          |
| **vm_os_sku**                         | A SKU of the image to be deployed                                                                                                                                      | string         | "sg-byol" - BYOL license;<br />"sg-ngtp" - NGTP PAYG license;<br />"sg-ngtx" - NGTX PAYG license;<br />                                                                                        |
| **vm_os_offer**                       | The name of the image offer to be deployed                                                                                                                              | string         | "check-point-cg-r81";<br />"check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";<br />                                                                              |
| **os_version**                        | GAIA OS version                                                                                                                                                        | string         | "R8110";<br />"R8120";<br />"R82";<br />                                                                                                                                                       |
| **bootstrap_script**                  | An optional script to run on the initial boot                                                                                                                          | string         | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"<br />                                                                          |
| **allow_upload_download**             | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point                                              | boolean        | true;<br />false;<br />                                                                                                                                                                       |
| **authentication_type**               | Specifies whether a password authentication or SSH Public Key authentication should be used                                                                             | string         | "Password";<br />"SSH Public Key";<br />                                                                                                                                                      |
| **availability_zones_num**            | A list of a single item of the Availability Zone where the Virtual Machine should be allocated                                                                          | string         | "centralus", "eastus2", "francecentral", "northeurope", "southeastasia", "westeurope", "westus2", "eastus", "uksouth"<br />                                                                     |
| **minimum_number_of_vm_instances**    | The minimum number of VMSS instances for this resource                                                                                                                 | number         | Valid values are in the range 0 - 10<br />                                                                                                                                                    |
| **maximum_number_of_vm_instances**    | The maximum number of VMSS instances for this resource                                                                                                                 | number         | Valid values are in the range 0 - 10<br />                                                                                                                                                    |
| **management_name**                   | The name of the management server as it appears in the configuration file                                                                                               | string         | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long<br />                                                                    |
| **management_IP**                     | The IP address used to manage the VMSS instances                                                                                                                       | string         | A valid IP address<br />                                                                                                                                                                       |
| **management_interface**              | Management option for the Gateways in the VMSS                                                                                                                         | string         | "eth0-public" - Manages the GWs using their external NIC's public IP address;<br />"eth0-private" - Manages the GWs using their external NIC's private IP address;<br />"eth1-private" - Manages the GWs using their internal NIC's private IP address;<br />**Default:** "eth1-private" |
| **configuration_template_name**       | The configuration template name as it appears in the configuration file                                                                                                | string         | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long<br />                                                                    |
| **frontend_load_distribution**        | The load balancing distribution method for the External Load Balancer                                                                                                   | string         | "Default" - None (5-tuple);<br />"SourceIP" - ClientIP (2-tuple);<br />"SourceIPProtocol" - ClientIP and protocol (3-tuple)<br />                                                               |
| **backend_load_distribution**         | The load balancing distribution method for the Internal Load Balancer                                                                                                   | string         | "Default" - None (5-tuple);<br />"SourceIP" - ClientIP (2-tuple);<br />"SourceIPProtocol" - ClientIP and protocol (3-tuple)<br />                                                               |
| **notification_email**                | An email address to notify about scaling operations                                                                                                                    | string         | Leave empty double quotes or enter a valid email address<br />                                                                                                                                 |
| **enable_custom_metrics**             | Indicates whether Custom Metrics will be used for VMSS Scaling policy and VM monitoring                                                                                 | boolean        | true;<br />false;<br />                                                                                                                                                                       |
| **enable_floating_ip**                | Indicates whether the load balancers will be deployed with floating IP                                                                                                  | boolean        | true;<br />false;<br />                                                                                                                                                                       |
| **deployment_mode**                   | Indicates which load balancer needs to be deployed. External + Internal (Standard), only External, only Internal                                                        | string         | Standard;<br />External;<br />Internal;<br />**Default:** "Standard"                                                                                                                                          |
| **admin_shell**                       | Enables selecting different admin shells                                                                                                                               | string         | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh;<br />**Default:** "/etc/cli.sh"                                                                                                                   |
| **serial_console_password_hash**      | Optional parameter, used to enable serial console connection in case of SSH key as authentication type                                                                 | string         |                                                                                                                                                                                                                                        |
| **maintenance_mode_password_hash**    | Maintenance mode password hash, relevant only for R81.20 and higher versions                                                                                           | string         |                                                                                                                                                                                                                                        |
| **nsg_id**                            | Optional ID for a Network Security Group that already exists in Azure. If not provided, will create a default NSG                                                      | string         | Existing NSG resource ID<br />**Default:** ""                                                                                                                                                                  |
| **add_storage_account_ip_rules**      | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location                                                   | boolean        | true;<br />false;<br />**Default:** false                                                                                                                                                                     |
| **storage_account_additional_ips**    | IPs/CIDRs that are allowed access to the Storage Account                                                                                                               | list(string)   | A list of valid IPs and CIDRs<br />**Default:** []                                                                                                                                                            |
| **security_rules**                    | SSecurity rules for the Network Security                                                                                                 | list(any)      | A security rule composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}<br />**Default:** []  |
| **admin_SSH_key**                     | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'                                                     | string         | **Default:** ""                                                                                                                                        |
| **is_blink**                    | Define if blink image is used for deployment | boolean      | true;<br />false;<br />**Default:** true  |
