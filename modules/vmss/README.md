# Check Point CloudGuard VMSS Module
This Terraform module deploys Check Point CloudGuard VMSS solution in Azure.
As part of the deployment the following resources can optionally be created (you can also reuse existing resources or skip creation where supported):
- Resource group (optional — can use an existing one)
- Virtual network (optional — can use an existing one)
- Network security group (optional — can use an existing one or skip entirely)
- Storage account (optional — "New", "Existing", "Managed" or "None")
- Role assignment (optional — created only when cloud metrics are enabled)
- External Load Balancer (optional — for Standard and External deployment modes)
- Internal Load Balancer (optional — for Standard and Internal deployment modes)

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
  disk_size                      = "200"
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
  disk_size                      = "200"
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
  - IPv6 health probe uses TCP port 8117
  - IPv6 outbound rule provides SNAT for out-bound traffic
  - Load balancing rules for both IPv4 and IPv6
- **Internal Load Balancer**: Gets dual-stack frontend IP configurations (IPv4 + IPv6 private IPs)
  - IPv6 health probe uses TCP port 8117
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

### Resource Group:
You can specify whether you want to create a new Resource Group or use an existing one:
- **To create a new Resource Group (default):**
  ```
  create_resource_group = true
  ```
- **To use an existing Resource Group:**
  ```
  create_resource_group = false
  resource_group_name   = "EXISTING RESOURCE GROUP NAME"
  resource_group_id     = "/subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>"
  ```
  The existing Resource Group must be in the same subscription and region as the deployment. Its ID can be copied from the Resource Group's Properties blade in the Azure Portal.

### Network Security Group (subnet-level association):
You can control NSG creation and subnet-level association:
- **Create a new NSG and associate with subnets (default):**
  ```
  enable_nsg = true
  ```
  When a new VNet is created, the NSG is automatically associated with both subnets. When using an existing VNet, the NSG is created but not associated (the user is responsible for association).
- **Use an existing NSG:**
  ```
  enable_nsg = true
  nsg_id     = "EXISTING NSG RESOURCE ID"
  ```
  Same association behavior as above — attached to subnets only when creating a new VNet.
- **Disable NSG entirely:**
  ```
  enable_nsg = false
  ```
  No NSG is created and no subnet associations are made.

**Note:** Azure [recommends keeping NSGs enabled](https://learn.microsoft.com/en-us/azure/security/fundamentals/network-best-practices) as part of network security best practices.

### Instance-Level Public IP:
You can control whether each VMSS instance gets a public IPv4 address on eth0:
- **Enable per-instance public IP (default):**
  ```
  instance_level_public_ipv4 = true
  ```
- **Disable per-instance public IP:**
  ```
  instance_level_public_ipv4 = false
  ```
  Instances are only reachable through a load balancer or private connectivity. When disabled, ensure your load balancer has the appropriate inbound and outbound rules configured to allow the required traffic.

### Deployment Mode (Load Balancers):
The `deployment_mode` variable controls which load balancers are created:
- **`Standard`** (default) — Creates both an External (public) and Internal (private) Load Balancer.
- **`External`** — Creates only the External Load Balancer.
- **`Internal`** — Creates only the Internal Load Balancer.
- **`None`** — No load balancers are created. Use this when load balancers are managed externally.

When using `deployment_mode = "None"`, you can pass externally managed LB backend pool IDs:
  ```
  deployment_mode      = "None"
  frontend_lb_pool_ids = ["EXTERNAL FRONTEND LB POOL ID"]
  backend_lb_pool_ids  = ["EXTERNAL BACKEND LB POOL ID"]
  ```
For IPv6 dual-stack with external load balancers:
  ```
  frontend_lb_pool_v6_ids = ["EXTERNAL FRONTEND LB POOL ID (IPv6)"]
  backend_lb_pool_v6_ids  = ["EXTERNAL BACKEND LB POOL ID (IPv6)"]
  ```

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
  When no specific zones are listed (the list is left empty):
  - If the number of availability zones above is greater than zero, the module automatically spreads instances across that many zones (starting from zone 1).
  - If the number of availability zones above is zero, no zones are used and instances are placed without zone affinity.

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

**Required permissions:** The Service Principal used to deploy the module must have permission to create role assignments at the Resource Group scope. Specifically, it requires the `Microsoft.Authorization/roleAssignments/write` action (granted by built-in roles such as **Owner** or **User Access Administrator**, or via a custom role). Without this permission, the deployment fails with:
```
authorization.RoleAssignmentsClient#Create: ... Status=403 Code="AuthorizationFailed"
... does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write' ...
```
If you cannot grant this permission, disable cloud metrics to skip the role assignment.

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
For more information, refer to the [Azure Terraform documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set#boot_diagnostics-1).

## Module's variables:
| Name | Description | Type | Allowed values | Default | Required |
| ---- | ----------- | ---- | -------------- | ------- | -------- |
| **client_secret** | The client secret value of the Service Principal used to deploy the solution | string | N/A | N/A | Yes |
| **client_id** | The client ID of the Service Principal used to deploy the solution | string | N/A | N/A | Yes |
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution | string | N/A | N/A | Yes |
| **subscription_id** | The subscription ID is used to pay for Azure cloud services | string | N/A | N/A | Yes |
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period.<br />Note: Resource group name must not contain reserved words based on: sk40179. | N/A | Yes |
| **create_resource_group** | Controls whether a new Resource Group is created or an existing one is used. When set to false, the module uses a pre-existing Resource Group matching `resource_group_name`. | boolean | true;<br />false; | true | No |
| **resource_group_id** | Azure Resource Group ID. Required only when using a pre-existing Resource Group instead of creating a new one. | string | A valid Azure Resource Group ID. | "" | No |
| **vmss_name** | The name of the Check Point VMSS Object. | string | 1-64 characters; alphanumerics and hyphens only; must not start or end with a hyphen.<br />Note: VMSS name must not contain reserved words based on: sk40179. | N/A | Yes |
| **location** | The region where the resources will be deployed at. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. | N/A | Yes |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`virtual-network`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`public-ip-prefix`<br/>`load-balancer`<br/>`route-table`<br/>`storage-account`<br/>`virtual-machine-scale-set`<br/>`custom-image`<br/>`autoscale-setting`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | N/A | {} | No |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images. | string | N/A | "noCustomUri" | No |
| **admin_username** | The username of the local administrator used for the Virtual Machines. Due to Azure limitations, 'notused' name can be used. | string | N/A | "notused" | No |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used. | string | "Password";<br />"SSH Public Key"; | N/A | Yes |
| **admin_password** | (Optional) Administrator password of the deployed VM. Required when authentication_type is 'Password'. | string | Password must have 3 of the following: 1 lowercase character, 1 uppercase character, 1 number, and 1 special character. | "" | No |
| **admin_SSH_key** | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'. | string | N/A | "" | No |
| **sic_key** | The Secure Internal Communication one-time secret used to set up trust between the cluster object and the management server. | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long. | N/A | Yes |
| **serial_console_password_hash** | (Optional) Password hash for serial console connection. Relevant when using SSH Public Key authentication. | string | N/A | "" | No |
| **maintenance_mode_password_hash** | (Optional) Maintenance mode password hash, relevant only for R81.20 and higher versions. | string | N/A | "" | No |
| **vm_size** | Specifies the size of Virtual Machine. | string | One of the supported Azure VM sizes (e.g. "Standard_D4ds_v5", "Standard_D8ds_v5"). | N/A | Yes |
| **disk_size** | Storage data disk size (GB) must be 100 for versions R81.20 and below. | string | A number in the range 100 - 3995 (GB). | "200" | No |
| **os_version** | GAIA OS version. | string | "R8110";<br />"R8120";<br />"R82";<br />"R8210"; | N/A | Yes |
| **vm_os_sku** | A SKU of the image to be deployed. | string | "sg-byol" - BYOL license;<br />"sg-ngtp" - NGTP PAYG license;<br />"sg-ngtx" - NGTX PAYG license; | N/A | Yes |
| **vm_os_offer** | The name of the image offer to be deployed. | string | "check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";<br />"check-point-cg-r8210"; | N/A | Yes |
| **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | boolean | true;<br />false; | N/A | Yes |
| **admin_shell** | Enables selecting different admin shells. | string | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh; | "/etc/cli.sh" | No |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt" | "" | No |
| **availability_zones_num** | An optional string specifying the amount of Availability Zones where the Virtual Machines should be allocated. Set to "0" to disable zonal deployment. | string | A whole number between 0 and the number of zones supported by the selected region. | "0" | No |
| **availability_zones** | An optional list specifying the Availability Zones to deploy into. When left empty, the module automatically uses zones starting from 1 up to the number of zones specified above. | list(string) | A list of distinct zones supported by the selected region (e.g. ["1", "2", "3"] or ["1"]). The list length must match the number of zones specified above, or be left empty. | [] | No |
| **is_blink** | Define if blink image is used for deployment. | boolean | true;<br />false; | true | No |
| **configuration_template_name** | The configuration template name as it appears in the configuration file. | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long. | N/A | Yes |
| **enable_custom_metrics** | Indicates whether Custom Metrics will be used for VMSS Scaling policy and VM monitoring. | boolean | true;<br />false; | true | No |
| **management_name** | The name of the management server as it appears in the configuration file. | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long. | N/A | Yes |
| **management_IP** | The IP address used to manage the VMSS instances. | string | A valid IP address. | N/A | Yes |
| **management_interface** | Management option for the Gateways in the VMSS. | string | "eth0-public" - Manages the GWs using their external NIC's public IP address;<br />"eth0-private" - Manages the GWs using their external NIC's private IP address;<br />"eth1-private" - Manages the GWs using their internal NIC's private IP address; | "eth1-private" | No |
| **vnet_name** | The name of the virtual network that will be created. | string | The name must begin with a letter or number, end with a letter, number, or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. | N/A | Yes |
| **existing_vnet_resource_group** | The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network. | string | N/A | "" | No |
| **frontend_subnet_name** | The Virtual Network frontend subnet name used for creating a new subnet with that name when create a new Virtual Network or used as the existing subnet name when using an existing Virtual Network. | string | N/A | N/A | Yes |
| **backend_subnet_name** | The Virtual Network backend subnet name used for creating a new subnet with that name when create a new Virtual Network or used as the existing subnet name when using an existing Virtual Network. | string | N/A | N/A | Yes |
| **address_space** | The address prefixes of the virtual network. | string | Valid CIDR block. | "10.0.0.0/16" | No |
| **subnet_prefixes** | The address prefixes to be used for created subnets. | list(string) | The subnets need to be contained within the address space for this virtual network (defined by the address_space variable). | ["10.0.0.0/24", "10.0.1.0/24"] | No |
| **enable_nsg** | Controls whether a Network Security Group is created or used. When true and a new VNet is created, the NSG is associated with the subnets. Set to false to skip NSG creation and association entirely. | boolean | true;<br />false; | true | No |
| **nsg_id** | The ID of an existing Network Security Group to use. If left empty (`""`), a new NSG will be created. Only relevant when `enable_nsg = true`. | string | Existing NSG resource ID | "" | No |
| **instance_level_public_ipv4** | Assign a public IPv4 address to each VMSS instance on eth0. Set to false when instances should only be reachable through a load balancer or private connectivity. | boolean | true;<br />false; | true | No |
| **storage_account_deployment_mode** | Choose the boot diagnostics storage account type. | string | New;<br/> Existing;<br/> Managed;<br/> None; | "New" | No |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location.<br/> Relevant only if `storage_account_deployment_mode = "New"` | boolean | true;<br />false; | false | No |
| **storage_account_additional_ips** | IPs/CIDRs that are allowed access to the Storage Account.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | list(string) | A list of valid IPs and CIDRs | [] | No |
| **existing_storage_account_name** | The existing storage account name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | N/A | "" | No |
| **existing_storage_account_resource_group_name** | The existing storage account resource group name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | N/A | "" | No |
| **sku** | The SKU used for the public IPs and Load Balancers. | string | "Basic";<br/>"Standard"; | "Standard" | No |
| **deployment_mode** | Indicates which load balancer needs to be deployed. External + Internal (Standard), only External, only Internal, or None (no load balancers created — manage externally). | string | Standard;<br />External;<br />Internal;<br />None; | "Standard" | No |
| **frontend_lb_pool_ids** | List of externally managed frontend (external) load balancer backend pool IDs to associate with the VMSS eth0 NIC. Used when `deployment_mode` is "None". | list(string) | N/A | [] | No |
| **backend_lb_pool_ids** | List of externally managed backend (internal) load balancer backend pool IDs to associate with the VMSS eth1 NIC. Used when `deployment_mode` is "None". | list(string) | N/A | [] | No |
| **frontend_lb_pool_v6_ids** | List of externally managed frontend load balancer backend pool IDs (IPv6) to associate with the VMSS eth0 NIC. Used when `deployment_mode` is "None" and `enable_ipv6` is true. | list(string) | N/A | [] | No |
| **backend_lb_pool_v6_ids** | List of externally managed backend load balancer backend pool IDs (IPv6) to associate with the VMSS eth1 NIC. Used when `deployment_mode` is "None" and `enable_ipv6` is true. | list(string) | N/A | [] | No |
| **backend_lb_IP_address** | A whole number that can be represented as a binary integer with no more than the number of digits remaining in the address after the given prefix. | number | Starting from the 5th IP address in a subnet. For example: subnet - 10.0.1.0/24, backend_lb_IP_address = 4, the LB IP is 10.0.1.4. | 4 | No |
| **lb_probe_port** | Port to be used for load balancer health probes and rules. | string | N/A | "8117" | No |
| **lb_probe_protocol** | Protocols to be used for load balancer health probes and rules. | string | "Tcp";<br/>"Http";<br/>"Https"; | "Tcp" | No |
| **lb_probe_unhealthy_threshold** | Number of consecutive failed health probes that must occur before a virtual machine is marked unhealthy. | number | N/A | 2 | No |
| **lb_probe_interval** | Interval of load balancer health probes in seconds. | number | N/A | 5 | No |
| **frontend_port** | Port that will be exposed to the external Load Balancer. | string | N/A | "80" | No |
| **backend_port** | Port that will be exposed to the external Load Balancer. | string | N/A | "80" | No |
| **frontend_load_distribution** | The load balancing distribution method for the External Load Balancer. | string | "Default" - None (5-tuple);<br />"SourceIP" - ClientIP (2-tuple);<br />"SourceIPProtocol" - ClientIP and protocol (3-tuple). | "Default" | No |
| **backend_load_distribution** | The load balancing distribution method for the Internal Load Balancer. | string | "Default" - None (5-tuple);<br />"SourceIP" - ClientIP (2-tuple);<br />"SourceIPProtocol" - ClientIP and protocol (3-tuple). | "Default" | No |
| **enable_floating_ip** | Indicates whether the load balancers will be deployed with floating IP. | boolean | true;<br />false; | true | No |
| **use_public_ip_prefix** | Indicates whether the public IP resources will be deployed with public IP prefix. | boolean | true;<br />false; | false | No |
| **create_public_ip_prefix** | Indicates whether the public IP prefix will be created or an existing one will be used. | boolean | true;<br />false; | false | No |
| **existing_public_ip_prefix_id** | The existing public IP prefix resource ID. | string | Existing public IP prefix resource ID | "" | No |
| **security_rules** | Security rules for the Network Security Group. | list(any) | A security rule composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description} | Allow all inbound traffic. | No |
| **number_of_vm_instances** | The default number of VMSS instances to deploy. The value must not be less than the minimum or greater than the maximum; if it is greater than the maximum, the maximum is used instead. | string | A whole number passed as a string (e.g. "2"). | "2" | No |
| **minimum_number_of_vm_instances** | The minimum number of VMSS instances for this resource. | string | A whole number passed as a string, in the range 0 - 99. | N/A | Yes |
| **maximum_number_of_vm_instances** | The maximum number of VMSS instances for this resource. | string | A whole number passed as a string, in the range 0 - 99. | N/A | Yes |
| **notification_email** | An email address to notify when an automatic scaling operation occurs (e.g. when CPU usage triggers scale-out or scale-in). | string | A valid email address or empty string to disable notifications. | "" | No |
| **enable_ipv6** | Enable dual-stack IPv6 support for the VMSS deployment. | boolean | true;<br />false; | false | No |
| **vnet_ipv6_address_space** | The IPv6 address space that is used by the Virtual Network. | string | Valid IPv6 CIDR block (e.g., "ace:cab:deca::/48"). | "ace:cab:deca::/48" | No |
| **subnet_ipv6_prefixes** | IPv6 address prefixes to be used for network subnets. Must be exactly /64 prefixes. | list(string) | List of two /64 IPv6 CIDR blocks (e.g., ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"]).<br />**Important:** Index [0] is used for the **frontend subnet**, index [1] is used for the **backend subnet**. | ["ace:cab:deca:deed::/64", "ace:cab:deca:deee::/64"] | No |
| **backend_lb_ipv6_address** | Static IPv6 address for the internal load balancer frontend. Leave empty for dynamic allocation. | string | Valid IPv6 address within the backend subnet prefix or empty string for dynamic allocation. | "ace:cab:deca:deee::a" | No |
| **ipv6_allocated_outbound_ports** | Number of allocated outbound ports for IPv6 SNAT on the external load balancer. | number | Valid range: 0-64000. | 1024 | No |
