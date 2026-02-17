# Check Point CloudGuard VMSS Module
This Terraform module deploys Check Point CloudGuard VMSS solution in azure.
As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- Storage account
- Role assignment - conditional creation
- External Load Balancer (for Standard and External deployment modes)
- Internal Load Balancer (for Standard and Internal deployment modes)

This solution uses the following modules:
- common - used for creating a resource group and defining common variables.
- vnet - used for creating new virtual network and subnets or using an existing virtual network.
- network-security-group - used for creating new network security groups and rules or using an existing network security group.
- storage-account - used for creating new storage account or using an existing one to use for the boot diagnostics.

For additional information,
please see the [CloudGuard Network for Azure Virtual Machine Scale Sets (VMSS) Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_VMSS_for_Azure/Default.htm) 

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
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/vmss"
  version = "~> 1.0"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  vmss_name           = "checkpoint-vmss-terraform"
  resource_group_name = "checkpoint-vmss-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  sic_key                        = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  vm_size                        = "Standard_D4ds_v5"
  disk_size                      = "100"
  os_version                     = "R82"
  vm_os_sku                      = "sg-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  availability_zones_num         = "3"
  availability_zones             = ["1", "2", "3"]
  configuration_template_name    = "vmss_template"
  enable_custom_metrics          = true

  # Management Variables
  management_name      = "mgmt"
  management_IP        = "13.92.42.181"
  management_interface = "eth1-private"

  # Networking Variables
  vnet_name                       = "checkpoint-vmss-vnet"
  frontend_subnet_name            = "Frontend"
  backend_subnet_name             = "Backend"
  address_space                   = "10.0.0.0/16"
  subnet_prefixes                 = ["10.0.1.0/24", "10.0.2.0/24"]
  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []

  # Load Balancers Variables
  deployment_mode              = "Standard"
  backend_lb_IP_address        = 4
  frontend_load_distribution   = "Default"
  backend_load_distribution    = "Default"
  enable_floating_ip           = true
  use_public_ip_prefix         = false
  create_public_ip_prefix      = false
  existing_public_ip_prefix_id = ""

  # Scale Set variables
  number_of_vm_instances         = 2
  minimum_number_of_vm_instances = 2
  maximum_number_of_vm_instances = 10
  notification_email             = ""
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
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/vmss"
  version = "1.0.6"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  vmss_name           = "checkpoint-vmss-terraform"
  resource_group_name = "checkpoint-vmss-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  sic_key                        = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  vm_size                        = "Standard_D4ds_v5"
  disk_size                      = "100"
  os_version                     = "R82"
  vm_os_sku                      = "sg-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  availability_zones_num         = "3"
  availability_zones             = ["1", "2", "3"]
  configuration_template_name    = "vmss_template"
  enable_custom_metrics          = true

  # Management Variables
  management_name      = "mgmt"
  management_IP        = "13.92.42.181"
  management_interface = "eth1-private"

  # Networking Variables - IPv4
  vnet_name                       = "checkpoint-vmss-vnet"
  frontend_subnet_name            = "Frontend"
  backend_subnet_name             = "Backend"
  address_space                   = "10.0.0.0/16"
  subnet_prefixes                 = ["10.0.1.0/24", "10.0.2.0/24"]
  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []

  # Load Balancers Variables
  deployment_mode              = "Standard"
  backend_lb_IP_address        = 4
  frontend_load_distribution   = "Default"
  backend_load_distribution    = "Default"
  enable_floating_ip           = true
  use_public_ip_prefix         = false
  create_public_ip_prefix      = false
  existing_public_ip_prefix_id = ""

  # Scale Set variables
  number_of_vm_instances         = 2
  minimum_number_of_vm_instances = 2
  maximum_number_of_vm_instances = 10
  notification_email             = ""

  # IPv6 Dual-Stack Configuration
  enable_ipv6                    = true
  vnet_ipv6_address_space        = "ace:cab:deca::/48"
  subnet_ipv6_prefixes           = ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"]
  backend_lb_ipv6_address        = "ace:cab:deca:deee::a"
  ipv6_allocated_outbound_ports  = 1024
}
```

</details>

## IPv6 Dual-Stack Support
This module supports IPv6 dual-stack networking alongside the default IPv4 configuration. When enabled, the deployment automatically creates additional IPv6 resources including dual-stack load balancers with IPv6 frontend configurations.

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
4. (Optional) Configure static IPv6 address for internal load balancer:
   ```hcl
   backend_lb_ipv6_address = "ace:cab:deca:deee::a"
   ```
   Leave empty (`""`) for dynamic allocation.
5. (Optional) Configure IPv6 outbound SNAT port allocation:
   ```hcl
   ipv6_allocated_outbound_ports = 1024
   ```

**IPv6 Architecture:**
- **External Load Balancer**: Gets dual-stack frontend IP configurations (IPv4 + IPv6 public IPs)
  - IPv6 health probe uses TCP port 443
  - IPv6 outbound rule provides SNAT for out-bound traffic
  - Load balancing rules for both IPv4 and IPv6
- **Internal Load Balancer**: Gets dual-stack frontend IP configurations (IPv4 + IPv6 private IPs)
  - IPv6 health probe uses TCP port 443
  - HA Ports configuration for internal traffic
- **VMSS Instances**: Each instance receives:
  - Frontend NIC (eth0): Public IPv4 + Private IPv4 + Private IPv6 addresses
  - Backend NIC (eth1): Private IPv4 + Private IPv6 addresses
  - No instance-level public IPv6 addresses (all traffic via load balancer)

**IPv6 Requirements:**
- **Subnet IPv6 Prefixes**: Must be exactly `/64` prefixes within the VNet address space
  - Frontend subnet: First `/64` prefix (e.g., `ace:cab:deca:deed::/64`)
  - Backend subnet: Second `/64` prefix (e.g., `ace:cab:deca:deee::/64`)

**Important Notes:**
- VMSS instances receive private IPv6 addresses only; public IPv6 is assigned to the External Load Balancer
- All IPv6 internet traffic flows through the External Load Balancer (inbound and outbound)
- IPv6 outbound connectivity is handled by the load balancer's outbound rule (no instance-level public IPs)

## Conditional creation
### Virtual Network:
You can specify whether you want to create a new Virtual Network or use an existing one:
- **To create a new Virtual Network:**
  ```
  address_space = "10.0.0.0/16"
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
  ```
- **To use an existing Virtual Network:**
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

### Availability types deployment:
- To define the number of zones for VMSS instances deployment in supported regions:
  ```
  availability_zones_num = "3"
  ```
  Otherwise, to deploy the solution in regions not supporting Availability Zones, or if the zone preference is not important:
  ```
  availability_zones_num = "0"
  ```
- To specify which zones to deploy into, set:
  ```
  availability_zones = ["1", "2", "3"]
  ```
  If availability_zones is not provided or is set to an empty list ([]), the deployment will still use multiple zones by default.

### Public IP Prefix:
To create new public IP prefix for the public IP:
  ```
  use_public_ip_prefix    = true
  create_public_ip_prefix = true
  ```
To use an existing public IP prefix for the public IP:
  ```
  use_public_ip_prefix         = true
  create_public_ip_prefix      = false
  existing_public_ip_prefix_id = "public IP prefix resource id"
  ```

### Cloud Metrics:
To create role assignment and enable CloudGuard metrics in order to send statuses and statistics collected from VMSS instances to the Azure Monitor service:
```
enable_custom_metrics = true
```

### Boot Diagnostics:
To use boot diagnostics you can choose the storage account type or you can disable the boot diagnostics entirely.<br/>
You can configure boot diagnostics by selecting the desired storage account deployment mode or disabling boot diagnostics entirely. The available options for `storage_account_deployment_mode` are:
- `New` Creates a new storage account to be used for boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "New"`
- `Exists` Uses an existing storage account for boot diagnostics.<br/>
Usages:
  ```
  storage_account_deployment_mode= "Existing"
  existing_storage_account_name  = "EXISTING_STORAGE_ACCOUNT_NAME"
  existing_storage_account_resource_group_name     = "EXISTING_STORAGE_ACCOUNT_RESOURCE_GROUP_NAME"
  ```
- `Managed`: Uses a managed (automatically created) storage account for boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "Managed"`
- `None`: Disables boot diagnostics.<br/>
Usage: `storage_account_deployment_mode = "None"`<br/>
**Note:** When deploying a Virtual Machine Scale Set (VMSS) using Terraform, Azure does not currently support deployment without boot diagnostics. Therefore, setting storage_account_deployment_mode = "None" behaves the same as "Managed" — a managed storage account will still be created automatically.
For more information, refer to the official - [Checkout the Azure Terraform documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set#boot_diagnostics-1)

## Module's variables:
| Name | Description | Type | Allowed values |
| ---- | ----------- | ---- | -------------- |
| **client_secret** | The client secret value of the Service Principal used to deploy the solution | string |  N/A  |
| **client_id** | The client ID of the Service Principal used to deploy the solution | string |  N/A  |
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution | string |  N/A  |
| **subscription_id** | The subscription ID is used to pay for Azure cloud services | string |  N/A  |
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period.<br />Note: Resource group name must not contain reserved words based on: sk40179. |
| **vmss_name** | The name of the Check Point VMSS Object. | string | Only alphanumeric characters are allowed, and the name must be 1-30 characters long.<br />Note: VMSS name must not contain reserved words based on: sk40179. |
| **location** | The region where the resources will be deployed at. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`virtual-network`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`public-ip-prefix`<br/>`load-balancer`<br/>`route-table`<br/>`storage-account`<br/>`virtual-machine-scale-set`<br/>`custom-image`<br/>`autoscale-setting`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | **Default:** {} |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images. | string | **Default:** "noCustomUri" |
| **admin_username** | The username of the local administrator used for the Virtual Machines. | string | **Default:** "azureuser" |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used. | string | "Password";<br />"SSH Public Key"; |
| **admin_password** | The password associated with the local administrator account on each cluster member. | string | Password must have 3 of the following: 1 lowercase character, 1 uppercase character, 1 number, and 1 special character. |
| **admin_SSH_key** | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'. | string | **Default:** "" |
| **sic_key** | The Secure Internal Communication one-time secret used to set up trust between the cluster object and the management server. | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long. |
| **serial_console_password_hash** | Optional parameter, used to enable serial console connection in case of SSH key as authentication type. | string | N/A |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions. | string | N/A |
| **vm_size** | Specifies the size of Virtual Machine. | string | A list of valid VM sizes (e.g., "Standard_D4ds_v5", "Standard_D8ds_v5", etc). |
| **disk_size** | Storage data disk size (GB) must be 100 for versions R81.20 and below. | string | A number in the range 100 - 3995 (GB).<br />**Default:** 100 |
| **os_version** | GAIA OS version. | string | "R8110";<br />"R8120";<br />"R82";<br />"R8210";<br />|
| **vm_os_sku** | A SKU of the image to be deployed. | string | "sg-byol" - BYOL license;<br />"sg-ngtp" - NGTP PAYG license;<br />"sg-ngtx" - NGTX PAYG license; |
| **vm_os_offer** | The name of the image offer to be deployed. | string | "check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";<br />"check-point-cg-r8210"; |
| **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | boolean | true;<br />false; |
| **admin_shell** | Enables selecting different admin shells. | string | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh;<br />**Default:** "/etc/cli.sh" |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt" |
| **availability_zones_num** | An optional string specifying the amount of Availability Zones where the Virtual Machines should be allocated. | string | "centralus", "eastus2", "francecentral", "northeurope", "southeastasia", "westeurope", "westus2", "eastus", "uksouth" |
| **availability_zones** | An optional parameter specifying the Availability Zones where the Virtual Machines should be allocated. | list(string) | ["1", "2", "3"];<br /> ["1"] |
| **is_blink** | Define if blink image is used for deployment. | boolean | true;<br />false;<br />**Default:** true |
| **configuration_template_name** | The configuration template name as it appears in the configuration file. | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long. |
| **enable_custom_metrics** | Indicates whether Custom Metrics will be used for VMSS Scaling policy and VM monitoring. | boolean | true;<br />false; |
| **management_name** | The name of the management server as it appears in the configuration file. | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long. |
| **management_IP** | The IP address used to manage the VMSS instances. | string | A valid IP address. |
| **management_interface** | Management option for the Gateways in the VMSS. | string | "eth0-public" - Manages the GWs using their external NIC's public IP address;<br />"eth0-private" - Manages the GWs using their external NIC's private IP address;<br />"eth1-private" - Manages the GWs using their internal NIC's private IP address;<br />**Default:** "eth1-private" |
| **vnet_name** | The name of the virtual network that will be created. | string | The name must begin with a letter or number, end with a letter, number, or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| **existing_vnet_resource_group** | The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network. | string | N/A |
| **frontend_subnet_name** | The Virtual Network frontend subnet name used for creating a new subnet with that name when create a new Virtual Network or used as the existing subnet name when using an existing Vritual Network. | string | N/A |
| **backend_subnet_name** | The Virtual Network backend subnet name used for creating a new subnet with that name when create a new Virtual Network or used as the existing subnet name when using an existing Vritual Network. | string | N/A |
| **address_space** | The address prefixes of the virtual network. | string | Valid CIDR block.<br />**Default:** "10.0.0.0/16" |
| **subnet_prefixes** | The address prefixes to be used for created subnets. | string | The subnets need to be contained within the address space for this virtual network (defined by the address_space variable).<br />**Default:** ["10.0.0.0/24", "10.0.1.0/24"] |
| **nsg_id** | Optional ID for a Network Security Group that already exists in Azure. If not provided, will create a default NSG. | string | Existing NSG resource ID<br />**Default:** "" |
| **storage_account_deployment_mode** | Choose the boot diagnostics storage account type. | string | New;<br/> Existing;<br/> Managed;<br/> None;<br/> **Default:** New |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location.<br/> Relevant only if `storage_account_deployment_mode = "New"` | boolean | true;<br />false;<br />**Default:** false |
| **storage_account_additional_ips** | IPs/CIDRs that are allowed access to the Storage Account.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | list(string) | A list of valid IPs and CIDRs<br />**Default:** [] |
| **existing_strorage_account_name** | The existing storage account name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **existing_strorage_account_resource_group_name** | The existing storage account resource group name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **deployment_mode** | Indicates which load balancer needs to be deployed. External + Internal (Standard), only External, only Internal. | string | Standard;<br />External;<br />Internal;<br />**Default:** "Standard" |
| **backend_lb_IP_address** | A whole number that can be represented as a binary integer with no more than the number of digits remaining in the address after the given prefix | number| Starting from the 5th IP address in a subnet. For example: subnet - 10.0.1.0/24, backend_lb_IP_address = 4, the LB IP is 10.0.1.4. |
| **lb_probe_port** | Port to be used for load balancer health probes and rules. | string | **Default:** "8117" |
| **lb_probe_protocol** | Protocols to be used for load balancer health probes and rules. | string | "TCP";<br/>"HTTP";<br/>"HTTPS";<br/>**Default:** "TCP" |
| **lb_probe_unhealthy_threshold** | Number of consecutive failed health probes that must occur before a virtual machine is marked unhealthy. | number | **Default:** 2 |
| **lb_probe_interval** | Interval of load balancer health probes in seconds. | number | **Default:** 5 |
| **frontend_load_distribution** | The load balancing distribution method for the External Load Balancer. | string | "Default" - None (5-tuple);<br />"SourceIP" - ClientIP (2-tuple);<br />"SourceIPProtocol" - ClientIP and protocol (3-tuple). |
| **backend_load_distribution** | The load balancing distribution method for the Internal Load Balancer. | string | "Default" - None (5-tuple);<br />"SourceIP" - ClientIP (2-tuple);<br />"SourceIPProtocol" - ClientIP and protocol (3-tuple). |
| **enable_floating_ip** | Indicates whether the load balancers will be deployed with floating IP. | boolean | true;<br />false;<br />**Default:** true |
| **use_public_ip_prefix** | Indicates whether the public IP resources will be deployed with public IP prefix. | boolean | true;<br />false;<br />**Default:** false |
| **create_public_ip_prefix** | Indicates whether the public IP prefix will be created or an existing one will be used. | boolean | true;<br />false;<br />**Default:** false |
| **existing_public_ip_prefix_id** | The existing public IP prefix resource ID. | string | Existing public IP prefix resource ID<br />**Default:** "" |
| **security_rules** | Security  rules for the Network Security. | list(any) | A security rule composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}<br />**Default:** [] |
| **number_of_vm_instances** | The default number of VMSS instances to deploy. | number | The number of VMSS instances must not be less then `minimum_number_of_vm_instances`. If the number of VMSS is greater then the `maximum_number_of_vm_instances` use the maximum number by default.<br/>**Default**: 2; |
| **minimum_number_of_vm_instances** | The minimum number of VMSS instances for this resource. | number | Valid values are in the range 0 - 10. |
| **maximum_number_of_vm_instances** | The maximum number of VMSS instances for this resource. | number | Valid values are in the range 0 - 10. |
| **notification_email** | An email address to notify about scaling operations. | string | Leave empty double quotes or enter a valid email address.
| **enable_ipv6** | Enable dual-stack IPv6 support for the VMSS deployment. | boolean | true;<br />false;<br />**Default:** false |
| **vnet_ipv6_address_space** | The IPv6 address space that is used by the Virtual Network. | string | Valid IPv6 CIDR block (e.g., "ace:cab:deca::/48").<br />**Default:** "ace:cab:deca::/48" |
| **subnet_ipv6_prefixes** | IPv6 address prefixes to be used for network subnets. Must be exactly /64 prefixes. | list(string) | List of two /64 IPv6 CIDR blocks (e.g., ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"]).<br />**Important:** Index [0] is used for the **frontend subnet**, index [1] is used for the **backend subnet**.<br />**Default:** ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"] |
| **backend_lb_ipv6_address** | Static IPv6 address for the internal load balancer frontend. Leave empty for dynamic allocation. | string | Valid IPv6 address within the backend subnet prefix or empty string for dynamic allocation.<br />**Default:** "ace:cab:deca:deee::a" |
| **ipv6_allocated_outbound_ports** | Number of allocated outbound ports for IPv6 SNAT on the external load balancer. | number | Valid range: 0-64000.<br />**Default:** 1024 |
