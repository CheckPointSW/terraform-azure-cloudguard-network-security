# Check Point CloudGuard MDS Module
This Terraform module deploys Check Point CloudGuard Network Security MDS solution in azure.
As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- Virtual Machine
- System assigned identity
- Storage account

This solution uses the following modules:
- common - used for creating a resource group and defining common variables.
- vnet - used for creating new virtual network and subnets or using an existing virtual network.
- network-security-group - used for creating new network security groups and rules or using an existing network security group.
- storage-account - used for creating new storage account or using an existing one to use for the boot diagnostics.

## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest).

**Example:**
```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/mds"
  version = "1.0.6"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  resource_group_name = "checkpoint-mds-rg-terraform"
  mds_name            = "checkpoint-mds-terraform"
  location            = "eastus"
  tags                = {}

  # Virtual Machine Instances Variables
  source_image_vhd_uri           = "noCustomUri"
  authentication_type            = "Password"
  admin_password                 = "xxxxxxxxxxxx"
  sic_key                        = "xxxxxxxxxxxx"
  serial_console_password_hash   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  installation_type              = "mds-primary"
  primary                        = "true"
  secondary                      = "false"
  logserver                      = "false"
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
  vnet_name                       = "checkpoint-mds-vnet"
  subnet_name                     = "checkpoint-mds-vnet-subnet"
  address_space                   = "10.0.0.0/16"
  subnet_prefix                   = "10.0.0.0/24"
  management_GUI_client_network   = "0.0.0.0/0"
  mds_enable_api                  = "disable"
  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []
}
```

## Conditional creation
### Virtual Network:
You can specify wether you want to create a new Virtual Network or use an existing one:
- To create a new Virtual Network:
  ```
  address_space = "10.0.0.0/16"
  ```
- To use an existing Virtual Network:
  ```
  address_space = ""
  existing_vnet_resource_group = "EXISTING VIRTUAL NETWORK RESOURCE GROUP NAME"
  ```
  When using an existing Virtual Network the variable `subnet_name` will be used as the name of the existing subnet inside the Virtual Network, you can also ignore the `address_prefix` when you use an existing Virtual Network.

### Availability types deployment:
To define the zone for MDS deployment in supported regions:
  ```
  zone = "3"
  ```
  Otherwise, to deploy the solution in regions not supporting Availability Zones:
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
|------|-------------|------|----------------|
| **client_secret** | The client secret value of the Service Principal used to deploy the solution | string |  N/A  |
| **client_id** | The client ID of the Service Principal used to deploy the solution | string |  N/A  |
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution | string |  N/A  |
| **subscription_id** | The subscription ID is used to pay for Azure cloud services | string |  N/A  |
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period. |
| **mds_name** | MDS name. | string | N/A |
| **location** | The region where the resources will be deployed at. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`virtual-network`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`route-table`<br/>`storage-account`<br/>`virtual-machine`<br/>`custom-image`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | **Default:** {} |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images. | string | **Default:** "noCustomUri" |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used. | string | "Password";<br/>"SSH Public Key". |
| **admin_password** | The password associated with the local administrator account on the mds. | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character. |
| **admin_SSH_key** | The SSH public key for SSH connections to the instance.<br/>Used when the authentication_type is 'SSH Public Key'. | string | **Default:** "" |
| **sic_key** | Set the Secure Internal Communication one time secret used to set up trust between the primary and secondary servers. SIC key must be provided if installing a secondary Multi-Domain Server or a Multi-Domain Log Server. | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long. |
| **serial_console_password_hash** | Optional parameter, used to enable serial console connection in case of SSH key as authentication type, to generate password hash use the command 'openssl passwd -6 PASSWORD' on Linux and paste it here. | string | N/A |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions, to generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here. | string | N/A |
| **installation_type** | Enables to select installation type- gateway/standalone | string | mds-primary;<br/>mds-secondary;<br/>mds-logserver. |
| **vm_size** | Specifies the size of Virtual Machine. | string | A list of valid VM sizes (e.g., "Standard_D4ds_v5", "Standard_D8ds_v5", etc). |
| **disk_size** | Storage data disk size size (GB). | string | A number in the range 100 - 3995 (GB). |
| **os_version** | GAIA OS version. | string | "R8110";<br/>"R8120";. |
| **vm_os_sku** | A sku of the image to be deployed. | string | "mgmt-byol" - BYOL license;<br/>"mgmt-25" - PAYG. |
| **vm_os_offer** | The name of the image offer to be deployed. | string | "check-point-cg-r8110";<br/>"check-point-cg-r8120";<br/>"check-point-cg-r82";. |
| **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | boolean | true;<br/>false. |
| **admin_shell** | Enables to select different admin shells. | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh.<br/>**Default:** "/etc/cli.sh" |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt".<br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it.<br/>**Default:** "" |
| **zone** | Specifies the Availability Zone the solution should be deployed in. | string | "1"<br />**Default:** "" |
| **vnet_name** | The name of virtual network that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| **existing_vnet_resource_group** | The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network. | string | N/A |
| **subnet_name** | The Virtual Network subnet name used for creating a new subnet with that name when create a new Virtual Network or used as the existing subnet name when using an existing Vritual Network. | string | N/A |
| **address_space** | The address space that is used by a Virtual Network. | string | A valid address in CIDR notation.<br/>**Default:** "10.0.0.0/16" |
| **subnet_prefix** | Address prefix to be used for network subnet. | string | A valid address in CIDR notation.<br/>**Default:** "10.0.0.0/24" |
| **management_GUI_client_network** | Allowed GUI clients - GUI clients network CIDR. | string | N/A |
| **mds_enable_api** | Enable api access to the mds. | string | "all";<br/>"management_only";<br/>"gui_clients";<br/>"disable".<br/>**Default:** "disable" |
| **nsg_id** | Optional ID for a Network Security Group that already exists in Azure, if not provided, will create a default NSG. | string | Existing NSG resource ID.<br/>**Default:** "" |
| **storage_account_deployment_mode** | Choose the boot diagnostics storage account type. | string | New;<br/> Existing;<br/> Managed;<br/> None;<br/> **Default:** New |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location, if false then accses will be allowed from all networks.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | boolean | true;<br/>false.<br/>**Default:** false |
| **storage_account_additional_ips** | IPs/CIDRs that are allowed access to the Storage Account.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | list(string) | A list of valid IPs and CIDRs.<br/>**Default:** [] |
| **existing_strorage_account_name** | The existing storage account name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **existing_strorage_account_resource_group_name** | The existing storage account resource group name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **security_rules** | Security rules for the Network Security. | list(any) | A list of valid security rules values.<br/>A security rule composed of:<br/>{name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}.<br/>**Default:** [{"name":"AllowAllInBound", "priority":"100", "direction":"Inbound", "access":"Allow", "protocol":"*", "source_port_ranges":"*", "destination_port_ranges":"", "description":"Allow all inbound connections", "source_address_prefix":"*", "destination_address_prefix":""}]. |