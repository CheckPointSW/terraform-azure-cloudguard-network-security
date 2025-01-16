# Check Point CloudGuard Single Gateway Module - New VNet 

This Terraform module deploys Check Point CloudGuard Network Security Single Gateway solution into a new VNet in azure.
As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- System assigned identity


This solution uses the following submodules:
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

  source  = "CheckPointSW/cloudguard-network-security/azure//modules/single_gateway_new_vnet"
  version = "1.0.2"

  source_image_vhd_uri            = "noCustomUri"
  resource_group_name             = "checkpoint-single-gw-terraform"
  single_gateway_name             = "checkpoint-single-gw-terraform"
  location                        = "eastus"
  vnet_name                       = "checkpoint-single-gw-vnet"
  address_space                   = "10.0.0.0/16"
  frontend_subnet_prefix          = "10.0.1.0/24"
  backend_subnet_prefix           = "10.0.2.0/24"
  management_GUI_client_network   = "0.0.0.0/0"
  admin_password                  = "xxxxxxxxxxxx"
  smart_1_cloud_token             = "xxxxxxxxxxxx"
  sic_key                         = "xxxxxxxxxxxx"
  vm_size                         = "Standard_D3_v2"
  disk_size                       = "110"
  vm_os_sku                       = "sg-byol"
  vm_os_offer                     = "check-point-cg-r8110"
  os_version                      = "R8110"
  bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  allow_upload_download           = true
  authentication_type             = "Password"
  enable_custom_metrics           = true
  admin_shell                     = "/etc/cli.sh"
  installation_type               = "gateway"
  serial_console_password_hash    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  nsg_id                          = ""
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []
}
```
  
## Conditional creation
-  To enable CloudGuard metrics in order to send statuses and statistics collected from the gateway instance to the Azure Monitor service:
  ```
  enable_custom_metrics = true
  ```


### Module's variables:
 | Name                                  | Description                                                                                                                                                      | Type           | Allowed values                                                                                                                                                                                                                                    |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **source_image_vhd_uri**              | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images                                               | string         | **Default:** "noCustomUri"                                                                                                                                                                                                                            |
| **resource_group_name**               | The name of the resource group that will contain the contents of the deployment                                                                                  | string         | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period                                                                                              |
| **single_gateway_name**               | The name of the Check Point single GW Object                                                                                                                     | string         | Only alphanumeric characters are allowed, and the name must be 1-30 characters long                                                                                                      |
| **location**                          | The region where the resources will be deployed at                                                                                                               | string         | The full list of Azure regions can be found at https://azure.microsoft.com/regions                                                                                                       |
| **vnet_name**                         | The name of virtual network that will be created                                                                                                                 | string         | The name must beginn with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens                              |
| **address_space**                     | The address prefixes of the virtual network                                                                                                                      | string         | Valid CIDR block<br />**Default:** "10.12.0.0/16"                                                                                                                                                                                                     |
| **frontend_subnet_prefix**            | The address prefix to be used for created frontend subnet                                                                                                        | string         | The subnets need to contain within the address space for this virtual network (defined by address_space variable)<br />**Default:** "10.12.0.0/24"                                                                                                   |
| **backend_subnet_prefix**             | The address prefix to be used for created backend subnet                                                                                                         | string         | The subnets need to contain within the address space for this virtual network (defined by address_space variable)<br />**Default:** "10.12.1.0/24"                                                                                                   |
| **management_GUI_client_network**     | Allowed GUI clients - GUI clients network CIDR                                                                                                                   | string         |                                                                                                                                                                                                                                       |
| **admin_password**                    | The password associated with the local administrator account on the gateway                                                                                       | string         | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character                                                                |
| **smart_1_cloud_token**               | Smart-1 Cloud token to connect automatically ***Gateway*** to Check Point's Security Management as a Service. Follow these instructions to quickly connect this member to Smart-1 Cloud | string         | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal                                                                                                           |
| **sic_key**                           | The Secure Internal Communication one-time secret used to set up trust between the gateway object and the management server                                       | string         | Only alphanumeric characters are allowed, and the value must be 12-30 characters long                                                                                                   |
| **vm_size**                           | Specifies the size of Virtual Machine                                                                                                                            | string         | Various valid sizes (e.g., "Standard_DS2_v2", "Standard_D4s_v3", etc.)                                                                                                                  |
| **disk_size**                         | Storage data disk size (GB)                                                                                                                                      | string         | A number in the range 100 - 3995 (GB)                                                                                                                                                                                          |
| **vm_os_sku**                         | A SKU of the image to be deployed                                                                                                                                | string         | "sg-byol" - BYOL license;<br />"sg-ngtp" - NGTP PAYG license;<br />"sg-ngtx" - NGTX PAYG license                                                                                        |
| **vm_os_offer**                       | The name of the image offer to be deployed                                                                                                                       | string         | "check-point-cg-r81";<br />"check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";                                                                              |
| **os_version**                        | GAIA OS version                                                                                                                                                  | string         | "R81";<br />"R8110";<br />"R8120";<br />"R82";                                                                                                                                           |
| **bootstrap_script**                  | An optional script to run on the initial boot                                                                                                                    | string         | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"<br />**Default:** ""                                                                          |
| **allow_upload_download**             | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point                                       | boolean        | true;<br />false;                                                                                                                                                                        |
| **authentication_type**               | Specifies whether a password authentication or SSH Public Key authentication should be used                                                                       | string         | "Password";<br />"SSH Public Key";                                                                                                                                                      |
| **enable_custom_metrics**             | Indicates whether CloudGuard Metrics will be used for gateway monitoring                                                                                          | boolean        | true;<br />false;<br />**Default:** true                                                                                                                                                                      |
| **admin_shell**                       | Enables selecting different admin shells                                                                                                                         | string         | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh;<br />**Default:** "/etc/cli.sh"                                                                                                                   |
| **installation_type**                 | Enables selecting installation type (gateway/standalone)                                                                                                         | string         | gateway;<br />standalone;                                                                                                                                                               |
| **serial_console_password_hash**      | Optional parameter, used to enable serial console connection in case of SSH key as authentication type                                                           | string         |                                                                                                                                                                                                                                       |
| **maintenance_mode_password_hash**    | Maintenance mode password hash, relevant only for R81.20 and higher versions                                                                                     | string         |                                                                                                                                                                                                                                       |
| **nsg_id**                            | Optional ID for a Network Security Group that already exists in Azure. If not provided, a **Default** NSG will be created                                             | string         | Existing NSG resource ID<br />**Default:** ""                                                                                                                                                                 |
| **add_storage_account_ip_rules**      | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location                                              | boolean        | true;<br />false;<br />**Default:** false                                                                                                                                                                     |
| **storage_account_additional_ips**    | IPs/CIDRs that are allowed access to the Storage Account                                                                                                          | list(string)   | A list of valid IPs and CIDRs<br />**Default:** []                                                                                                                                                            |
| **security_rules**                    | SSecurity rules for the Network Security                                                                                                 | list(any)      | A security rule composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}<br />**Default:** []  |
| **admin_SSH_key**                     | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'                                                     | string         | **Default:** ""                                                                                                                                                                                                                                      |
| **is_blink**                    | Define if blink image is used for deployment | boolean      | true;<br />false;<br />**Default:** true  |
