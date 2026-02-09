# Check Point CloudGuard Single Gateway Module

Terraform module which deploys a Check Point CloudGuard Network Security Single Gateway solution in Azure with IPv4 and IPv6 dual-stack support.

As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- System assigned identity
- Storage account
- Standard Load Balancer (when IPv6 is enabled)

This solution uses the following submodules:
- common - used for creating a resource group and defining common variables.
- vnet - used for creating new virtual network and subnets.
- network_security_group - used for creating new network security groups and rules.
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
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/single-gateway"
  version = "~> 1.0"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  resource_group_name = "checkpoint-single-rg-terraform"
  single_gateway_name = "checkpoint-single-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  sic_key                        = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  installation_type              = "gateway"
  vm_size                        = "Standard_D4ds_v5"
  disk_size                      = "110"
  os_version                     = "R82"
  vm_os_sku                      = "sg-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  enable_custom_metrics          = true
  zone                           = ""

  # Smart-1 Cloud Variables
  smart_1_cloud_token = "xxxxxxxxxxxx"

  # Management Variables
  management_GUI_client_network = "0.0.0.0/0"

  # Networking Variables
  vnet_name                       = "checkpoint-single-gw-vnet"
  frontend_subnet_name            = "Frontend"
  backend_subnet_name             = "Backend"
  address_space                   = "10.0.0.0/16"
  subnet_prefixes                 = ["10.0.1.0/24", "10.0.2.0/24"]
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
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/single-gateway"
  version = "1.0.6"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  resource_group_name = "checkpoint-single-rg-terraform"
  single_gateway_name = "checkpoint-single-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  sic_key                        = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  installation_type              = "gateway"
  vm_size                        = "Standard_D4ds_v5"
  disk_size                      = "110"
  os_version                     = "R82"
  vm_os_sku                      = "sg-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  enable_custom_metrics          = true
  zone                           = ""

  # Smart-1 Cloud Variables
  smart_1_cloud_token = "xxxxxxxxxxxx"

  # Management Variables
  management_GUI_client_network = "0.0.0.0/0"

  # Networking Variables - IPv4
  vnet_name                       = "checkpoint-single-gw-vnet"
  frontend_subnet_name            = "Frontend"
  backend_subnet_name             = "Backend"
  address_space                   = "10.0.0.0/16"
  subnet_prefixes                 = ["10.0.0.0/24", "10.0.1.0/24"]

  # IPv6 Dual-Stack Configuration
  enable_ipv6              = true
  vnet_ipv6_address_space  = "ace:cab:deca::/48"
  subnet_ipv6_prefixes     = ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"]

  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []
}
```

</details>

## IPv6 Dual-Stack Support
This module supports IPv6 dual-stack networking alongside the default IPv4 configuration. When enabled, the deployment automatically creates additional IPv6 resources including a Standard Load Balancer with IPv6 public IP.

**To enable IPv6 dual-stack:**
1. Set `enable_ipv6 = true` in your module configuration
2. Configure the IPv6 address space for your Virtual Network:
   ```hcl
   vnet_ipv6_address_space = "ace:cab:deca::/48"
   ```
3. Configure IPv6 subnet prefixes (one /64 prefix per subnet):
   ```hcl
   subnet_ipv6_prefixes = ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"]
   ```
4. Configure Network Security Group rules to allow IPv6 traffic using the `security_rules` variable:
   ```hcl
   security_rules = [
     {
       name                       = "AllowHTTPv6"
       priority                   = "110"
       direction                  = "Inbound"
       access                     = "Allow"
       protocol                   = "Tcp"
       source_port_ranges         = "*"
       destination_port_ranges    = "80"
       source_address_prefix      = "::/0"
       destination_address_prefix = "::/0"
       description                = "Allow HTTP IPv6"
     }
   ]
   ```
**IPv6 Requirements:**
- **Subnet IPv6 Prefixes**: Must be exactly `/64` prefixes within the VNet address space
  - Frontend subnet: First `/64` prefix (e.g., `ace:cab:deca:deed::/64`)
  - Backend subnet: Second `/64` prefix (e.g., `ace:cab:deca:deee::/64`)
- **Standard Load Balancer**: Required for IPv6 traffic management (automatically created with Standard SKU public IP)
- **Route Tables**: IPv6 routes must use `next_hop_type = "None"` to enforce all traffic through the Load Balancer

**Important Notes:**
- Gateway VM receives private IPv6 addresses only; public IPv6 is assigned to the Load Balancer
- All IPv6 internet traffic flows through the Load Balancer (inbound and outbound)
- IPv6 health probe uses TCP port 8117
## Conditional creation
### Virtual Network:
You can specify whether you want to create a new Virtual Network or use an existing one:
- To create a new Virtual Network:
  ```
  address_space = "10.0.0.0/16"
  ```
- To use an existing Virtual Network:
  ```
  address_space = ""
  existing_vnet_resource_group = "EXISTING VIRTUAL NETWORK RESOURCE GROUP NAME"
  ```
  
  When using an existing Virtual Network:
  - The `frontend_subnet_name` and `backend_subnet_name` variables specify the names of the existing subnets to use.
  - The `subnet_prefixes` variable can be set but will be ignored when using an existing vnet. It is only used when creating a new vnet.

**IPv6 with Existing VNet:**
When using an existing VNet with IPv6 enabled (`enable_ipv6 = true`):
- The `vnet_ipv6_address_space` variable can be set but will be ignored when using an existing vnet. It is only used when creating a new vnet.
- The `subnet_ipv6_prefixes` variable can be set but will be ignored when using an existing vnet. It is only used when creating a new vnet.
- The module automatically detects all IPv6 network configuration from Azure when using an existing vnet.

### Cloud Metrics:
To enable CloudGuard metrics in order to send statuses and statistics collected from the gateway instance to the Azure Monitor service:
```
enable_custom_metrics = true
```

### Boot Diagnostics:
You can configure boot diagnostics by selecting the desired storage account deployment mode or disabling boot diagnostics entirely. The available options for `storage_account_deployment_mode` are:
- `New` Creates a new storage account to be used for boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "New"`
- `Exists` Uses an existing storage account for boot diagnostics.<br/>
Usages:
  ```
  storage_account_deployment_mode                  = "Existing"
  existing_storage_account_name                    = "EXISTING_STORAGE_ACCOUNT_NAME"
  existing_storage_account_resource_group_name     = "EXISTING_STORAGE_ACCOUNT_RESOURCE_GROUP_NAME"
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
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period. |
| **single_gateway_name** | The name of the Check Point single GW Object. | string | Only alphanumeric characters are allowed, and the name must be 1-30 characters long. |
| **location** | The region where the resources will be deployed at. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`virtual-network`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`route-table`<br/>`storage-account`<br/>`virtual-machine`<br/>`custom-image`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | **Default:** {} |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images. | string | **Default:** "noCustomUri" |
| **admin_username** | Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used. | string | **Default:** "notused" |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used. | string | "Password";<br />"SSH Public Key"; |
| **admin_password** | The password associated with the local administrator account on the gateway. | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character. |
| **admin_SSH_key** | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'. | string | **Default:** "" |
| **sic_key** | The Secure Internal Communication one-time secret used to set up trust between the gateway object and the management server | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long. |
| **serial_console_password_hash** | Optional parameter, used to enable serial console connection in case of SSH key as authentication type. | string | N/A |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions. | string | N/A |
| **installation_type** | Enables selecting installation type (gateway/standalone). | string | gateway;<br />standalone; |
| **vm_size** | Specifies the size of Virtual Machine. | string | A list of valid VM sizes (e.g., "Standard_D4ds_v5", "Standard_D8ds_v5", etc). |
| **disk_size** | Storage data disk size (GB). | string | A number in the range 100 - 3995 (GB). |
| **os_version** | GAIA OS version. | string | "R8110";<br />"R8120";<br />"R82";<br />"R8210"; |
| **vm_os_sku** | A SKU of the image to be deployed. | string | "sg-byol" - BYOL license;<br />"sg-ngtp" - NGTP PAYG license;<br />"sg-ngtx" - NGTX PAYG license; |
| **vm_os_offer** | The name of the image offer to be deployed. | string | "check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";<br />"check-point-cg-r8210"; |
| **allow_upload_download**| Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | boolean | true;<br />false; |
| **admin_shell** | Enables selecting different admin shells. | string | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh;<br />**Default:** "/etc/cli.sh" |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"<br />**Default:** "" |
| **is_blink** | Define if blink image is used for deployment. | boolean | true;<br />false;<br />**Default:** true |
| **enable_custom_metrics**| Indicates whether CloudGuard Metrics will be used for gateway monitoring. | boolean | true;<br />false;<br />**Default:** true |
| **zone** | Optional parameter, specifies the Availability Zone the solution should be deployed in. | string | "1"<br />**Default:** "" |
| **smart_1_cloud_token** | Smart-1 Cloud token to connect automatically ***Gateway*** to Check Point's Security Management as a Service. Follow these instructions to quickly connect this member to Smart-1 Cloud. | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. |
| **management_GUI_client_network** | Allowed GUI clients - GUI clients network CIDR | string | N/A |
| **vnet_name** | The name of virtual network that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| **existing_vnet_resource_group** | The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network. | string | **Default:** "" |
| **frontend_subnet_name** | The Virtual Network subnet name for the frontend interface. | string | N/A |
| **backend_subnet_name** | The Virtual Network subnet name for the backend interface. | string | N/A |
| **address_space** | The address prefixes of the virtual network. | string | Valid CIDR block<br />**Default:** "10.0.0.0/16" |
| **subnet_prefixes** | Address prefix to be used for network subnets. | list(string) | The subnets need to be contained within the address space for this virtual network (defined by the address_space variable).<br />**Important:** Index [0] is used for the **frontend subnet**, index [1] is used for the **backend subnet**.<br />**Default:** ["10.0.0.0/24", "10.0.1.0/24"] |
| **enable_ipv6** | Enable IPv6 dual-stack networking. When enabled, creates additional IPv6 resources including Standard Load Balancer, IPv6 public IP, and dual-stack network interfaces. | bool | true;<br/>false;<br/>**Default:** false |
| **vnet_ipv6_address_space** | The IPv6 address space for the virtual network. Required when enable_ipv6 is true. | string | Valid IPv6 CIDR block<br/>**Default:** "ace:cab:deca::/48" |
| **subnet_ipv6_prefixes** | IPv6 address prefixes to be used for network subnets. Required when enable_ipv6 is true. Must contain one /64 prefix for each subnet. | list(string) | List of valid IPv6 CIDR blocks (must be /64 prefixes within the VNet IPv6 address space)<br />**Important:** Index [0] is used for the **frontend subnet**, index [1] is used for the **backend subnet**.<br/>**Default:** ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"] |
| **nsg_id** | Optional ID for a Network Security Group that already exists in Azure. If not provided, a **Default** NSG will be created. | string | Existing NSG resource ID<br />**Default:** "" |
| **storage_account_deployment_mode** | Choose the boot diagnostics storage account type. | string | New;<br/> Existing;<br/> Managed;<br/> None;<br/> **Default:** New |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | boolean | true;<br />false;<br />**Default:** false |
| **storage_account_additional_ips** | IPs/CIDRs that are allowed access to the Storage Account.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | list(string) | A list of valid IPs and CIDRs<br />**Default:** [] |
| **existing_storage_account_name** | The existing storage account name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **existing_storage_account_resource_group_name** | The existing storage account resource group name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **sku** | SKU | string | **Default:** "Standard" |
| **security_rules** | Security  rules for the Network Security. | list(any) | A security rule composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}<br />**Default:** [] |