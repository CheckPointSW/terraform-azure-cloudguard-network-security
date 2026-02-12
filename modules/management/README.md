# Check Point CloudGuard Management Module
This Terraform module deploys Check Point CloudGuard Network Security Management solution in azure.
As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- Virtual Machine
- System assigned identity
- Storage account

This solution uses the following submodules:
- common - used for creating a resource group and defining common variables.
- vnet - used for creating new virtual network and subnets or using an existing virtual network.
- network-security-group - used for creating new network security groups and rules or using an existing network security group.
- storage-account - used for creating new storage account or using an existing one to use for the boot diagnostics.

## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest).

### Example Deployments

<details>
<summary><b>IPv4 Only Deployment Example</b></summary>
<br>

```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/management"
  version = "~> 1.0"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  resource_group_name = "checkpoint-mgmt-terraform"
  mgmt_name           = "checkpoint-mgmt-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  vm_size                        = "Standard_D4ds_v5"
  disk_size                      = "110"
  os_version                     = "R82"
  vm_os_sku                      = "mgmt-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  zone                           = ""

  # Networking Variables
  vnet_name                       = "checkpoint-mgmt-vnet"
  subnet_name                     = "checkpoint-mgmt-vnet-subnet"
  address_space                   = "10.0.0.0/16"
  subnet_prefix                   = "10.0.0.0/24"
  management_GUI_client_network   = "0.0.0.0/0"
  mgmt_enable_api                 = "disable"
  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []
}
```

</details>

<details>
<summary><b>IPv6 Dual-Stack Deployment Example</b></summary>
<br>

```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/management"
  version = "1.0.6"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  resource_group_name = "checkpoint-mgmt-terraform"
  mgmt_name           = "checkpoint-mgmt-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  vm_size                        = "Standard_D4ds_v5"
  disk_size                      = "110"
  os_version                     = "R82"
  vm_os_sku                      = "mgmt-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  zone                           = ""

  # Networking Variables - IPv4
  vnet_name                     = "checkpoint-mgmt-vnet"
  subnet_name                   = "checkpoint-mgmt-subnet"
  address_space                 = "10.0.0.0/16"
  subnet_prefix                 = "10.0.0.0/24"
  management_GUI_client_network = "0.0.0.0/0"
  
  # IPv6 Dual-Stack Configuration
  enable_ipv6                        = true
  vnet_ipv6_address_space            = "ace:cab:deca::/48"
  subnet_ipv6_prefix                 = "ace:cab:deca:deed::/64"
  management_GUI_client_network_ipv6 = "::/0"   # Allow access from any IPv6 address (use "" to deny all IPv6 addresses)
  
  mgmt_enable_api                 = "disable"
  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []
}
```

</details>

## IPv6 Dual-Stack Support
This module supports IPv6 dual-stack networking alongside the default IPv4 configuration. When enabled, the management server is accessible via both IPv4 and IPv6 public IPs.

> **Note:** For required configuration to enable IPv6 support on Check Point appliances, see [sk170760](https://support.checkpoint.com/results/sk/sk170760).

**To enable IPv6 dual-stack:**
1. Set `enable_ipv6 = true` in your module configuration
2. Configure the IPv6 address space for your Virtual Network:
   ```hcl
   vnet_ipv6_address_space = "ace:cab:deca::/48"
   ```
3. Configure the IPv6 subnet prefix (must be a /64 prefix):
   ```hcl
   subnet_ipv6_prefix = "ace:cab:deca:deed::/64"
   ```
4. Optionally, configure allowed IPv6 clients for management access:
   ```hcl
   management_GUI_client_network_ipv6 = "::/0"  # Allow all IPv6, or specify a specific IPv6 CIDR
   # management_GUI_client_network_ipv6 = ""    # Set to empty string to deny all IPv6-specific NSG rules
   ```

**IPv6 Requirements:**
- **Subnet IPv6 Prefix**: Must be exactly a `/64` prefix within the VNet address space (e.g., `ace:cab:deca:deed::/64`)

**Important Notes:**
- Management server receives both IPv4 and IPv6 public IPs for direct access
- IPv6 NSG rules mirror the IPv4 rules (SSH, GAiA portal on port 443, SmartConsole on ports 18190 and 19009)

## Conditional creation
### Virtual Network:
You can specify whether you want to create a new Virtual Network or use an existing one:
- **To create a new Virtual Network:**
  ```
  address_space = "10.0.0.0/16"
  subnet_prefix = "10.0.0.0/24"
  ```
- **To use an existing Virtual Network:**
  ```
  address_space = ""
  existing_vnet_resource_group = "EXISTING VIRTUAL NETWORK RESOURCE GROUP NAME"
  ```
  
  When using an existing Virtual Network:
  - The `subnet_name` variable specifies the name of the existing subnet to use.
  - The `subnet_prefix` variable can be set but will be ignored when using an existing vnet. It is only used when creating a new vnet.

**IPv6 with Existing VNet:**
When using an existing VNet with IPv6 enabled (`enable_ipv6 = true`):
- The `vnet_ipv6_address_space` variable can be set but will be ignored when using an existing vnet. It is only used when creating a new vnet.
- The `subnet_ipv6_prefix` variable can be set but will be ignored when using an existing vnet. It is only used when creating a new vnet.
- The module automatically detects all IPv6 network configuration from Azure when using an existing vnet.

### Availability types deployment:
To define the zone for the Management deployment in Availability Zones supported regions:
```
zone = "1"
```
If the zone preference is not important, or the selected region does not support Availability Zones, leave the parameter as an empty string or omit it entirely:
```
zone = ""
```

### Boot Diagnostics:
You can configure boot diagnostics by selecting the desired storage account deployment mode or disabling boot diagnostics entirely. The available options for `storage_account_deployment_mode` are:
- `New` Creates a new storage account to be used for boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "New"`
- `Exists` Uses an existing storage account for boot diagnostics.<br/>
Usages:
  ```
  storage_account_deployment_mode              = "Existing"
  existing_storage_account_name                = "EXISTING_STORAGE_ACCOUNT_NAME"
  existing_storage_account_resource_group_name = "EXISTING_STORAGE_ACCOUNT_RESOURCE_GROUP_NAME"
  ```
- `Managed`: Uses a managed (automatically created) storage account for boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "Managed"`
- `None`: Disables boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "None"`<br/>

## Module's variables:
| Name | Description | Type | Allowed values |
| ---- | ----------- | ---- | -------------- |
| **client_secret** | The client secret value of the Service Principal used to deploy the solution | string |  N/A  |
| **client_id** | The client ID of the Service Principal used to deploy the solution | string |  N/A  |
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution | string |  N/A  |
| **subscription_id** | The subscription ID is used to pay for Azure cloud services | string |  N/A  |
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens, and parenthesis and cannot end in a period. |
| **resource_group_create** | Define if Azure Resource Group should be created | boolean | true;<br />false;<br />**Default:** true |
| **mgmt_name** | Management name | string. | N/A |
| **location** | The region where the resources will be deployed. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. | 
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`virtual-network`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`route-table`<br/>`storage-account`<br/>`virtual-machine`<br/>`custom-image`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | **Defaults:** {} |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use `noCustomUri` if you want to use marketplace images. | string | **Default:** "noCustomUri" |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used. | string | "Password";<br />"SSH Public Key"; |
| **admin_password**| The password associated with the local administrator account on each cluster member. | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character.|
| **admin_SSH_key** | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'. | string | **Default:** "" |
| **serial_console_password_hash** | Optional parameter, used to enable serial console connection in case of SSH key as authentication type. To generate a password hash, use the command `openssl passwd -6 PASSWORD` on Linux and paste it here. | string | N/A |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions. To generate a password hash, use the command `grub2-mkpasswd-pbkdf2` on Linux and paste it here. | string | N/A |
| **vm_size** | Specifies the size of the Virtual Machine. | string | A list of valid VM sizes (e.g., "Standard_D4ds_v5", "Standard_D8ds_v5", etc). |
| **disk_size** | Storage data disk size (GB). | string | A number in the range 100 - 3995 (GB). |
| **os_version** | GAIA OS version. | string | "R8110";<br />"R8120";<br />"R82";<br />"R8210";<br />**Defaults:**R82 |
| **vm_os_sku** | A SKU of the image to be deployed. | string | "mgmt-byol" - BYOL license;<br />"mgmt-25" - PAYG;.|
| **vm_os_offer** | The name of the image offer to be deployed. | string | "check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";<br />"check-point-cg-r8210";. |
| **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | boolean | true;<br />false;|
| **admin_shell** | Enables selecting different admin shells | string | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh;<br />**Default:** "/etc/cli.sh" |
| **bootstrap_script**. | An optional script to run on the initial boot. | string | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"<br />**Default:** "" |
| **zone** | Optional parameter, specifies the Availability Zone the solution should be deployed in. | string | "1"<br />**Default:** "" |
| **vnet_name** | The name of the virtual network that will be created. | string | The name must begin with a letter or number, end with a letter, number, or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| **existing_vnet_resource_group** | The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network. | string | N/A |
| **subnet_name** | The Virtual Network subnet name used for creating a new subnet with that name when create a new Virtual Network or used as the existing subnet name when using an existing Vritual Network. | string | N/A |
| **address_space** | The address space that is used by a Virtual Network. | string | A valid address in CIDR notation<br />**Default:** "10.0.0.0/16" |
| **subnet_prefix** | Address prefix to be used for the network subnet. | string | A valid address in CIDR notation<br />**Default:** "10.0.0.0/24" |
| **enable_ipv6** | Enable IPv6 dual-stack networking. When enabled, creates additional IPv6 resources including IPv6 public IP and dual-stack network interface. | bool | true;<br/>false;<br/>**Default:** false |
| **vnet_ipv6_address_space** | The IPv6 address space for the virtual network. Required when enable_ipv6 is true. | string | Valid IPv6 CIDR block<br/>**Default:** "ace:cab:deca::/48" |
| **subnet_ipv6_prefix** | IPv6 address prefix to be used for the management subnet. Required when enable_ipv6 is true. Must be a /64 prefix. | string | Valid IPv6 CIDR block (must be a /64 prefix within the VNet IPv6 address space)<br/>**Default:** "ace:cab:deca:deed::/64" |
| **management_GUI_client_network** | Allowed GUI clients - GUI clients network CIDR or '*' for any (IPv4 and IPv6). | string | Valid IPv4 CIDR block or "*"<br />**Default:** "0.0.0.0/0" |
| **management_GUI_client_network_ipv6** | Allowed GUI clients - GUI clients network IPv6 CIDR. Used when enable_ipv6 is true. Set to "" (empty string) to deny all IPv6-specific NSG rules. | string | Valid IPv6 CIDR block or "" to deny all IPv6 NSG rules<br/>**Default:** "::/0" |
| **mgmt_enable_api** | Enable API access to the management. | string | "all";<br />"management_only";<br />"gui_clients";<br />"disable";<br />**Default:** "disable" |
| **nsg_id** | Optional ID for a Network Security Group that already exists in Azure. If not provided, a default NSG will be created. | string | Existing NSG resource ID<br />**Default:** "" |
| **storage_account_deployment_mode** | Choose the boot diagnostics storage account type. | string | New;<br/> Existing;<br/> Managed;<br/> None;<br/> **Default:** New |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location. If false, then access will be allowed from all networks.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | boolean | true;<br />false;<br />**Default:** false |
| **storage_account_additional_ips**| IPs/CIDRs that are allowed access to the Storage Account.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | list(string) | A list of valid IPs and CIDRs<br />**Default:** [] |
| **existing_strorage_account_name** | The existing storage account name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **existing_strorage_account_resource_group_name** | The existing storage account resource group name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **security_rules** | Security  rules for the Network Security. | list(any) | A security rule is composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}<br />**Default:** [] |