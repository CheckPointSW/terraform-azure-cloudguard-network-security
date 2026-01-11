# Check Point CloudGuard High Availability Module
This Terraform module deploys Check Point CloudGuard Network Security High Availability solution in azure.
As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- System assigned identity
- Availability Set - conditional creation
- Storage account

For additional information,
please see the [CloudGuard Network for Azure High Availability Cluster Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_Azure_HA_Cluster/Default.htm)

This solution uses the following submodules:
- common - used for creating a resource group and defining common variables.
- vnet - used for creating new virtual network and subnets.
- network_security_group - used for creating new network security groups and rules.
- storage-account - used for creating new storage account or using an existing one to use for the boot diagnostics.

## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest).

**Example:**
```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/high-availability"
  version = "1.0.9"

  # Authentication Variables
  client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  tenant_id           = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  resource_group_name = "checkpoint-ha-terraform"
  cluster_name        = "checkpoint-ha-terraform"
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
  disk_size                      = "110"
  os_version                     = "R82"
  vm_os_sku                      = "sg-byol"
  vm_os_offer                    = "check-point-cg-r82"
  allow_upload_download          = true
  admin_shell                    = "/etc/cli.sh"
  bootstrap_script               = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  enable_custom_metrics          = true
  availability_type              = "Availability Zone"
  availability_zones             = ["1", "2"]

  # Smart-1 Cloud Variables
  smart_1_cloud_token_a = "xxxxxxxxxxxx"
  smart_1_cloud_token_b = "xxxxxxxxxxxx"

  # Networking Variables
  vnet_name                       = "checkpoint-ha-vnet"
  frontend_subnet_name            = "Frontend"
  backend_subnet_name             = "Backend"
  address_space                   = "10.0.0.0/16"
  subnet_prefixes                 = ["10.0.1.0/24", "10.0.2.0/24"]
  nsg_id                          = ""
  storage_account_deployment_mode = "New"
  add_storage_account_ip_rules    = false
  storage_account_additional_ips  = []
  vips_names                      = []

  # Load Balancers Variables
  enable_floating_ip           = true
  use_public_ip_prefix         = false
  create_public_ip_prefix      = false
  existing_public_ip_prefix_id = ""
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
  When using an existing Virtual Network the variable `frontend_subnet_name` and `backend_subnet_name` will be used as the name of the existing subnets inside the Virtual Network, you can also ignore the `address_prefixes` when you use an existing Virtual Network.

### Availability types deployment:
- To deploy the solution based on Azure Availability Set and create a new Availability Set for the virtual machines:
  ```
  availability_type = "Availability Set"
  ```
  Otherwise, to deploy the solution based on Azure Availability Zone in supported regions:
  ```
  availability_type = "Availability Zone"
  ```

- To specify which zones to deploy into (up to 2 zones for HA), set:
  ```
  availability_zones = ["1", "2"]
  ```
  If availability_zones is not provided or is set to an empty list ([]), the deployment will still use multiple zones by default.
  
### Custom metrics:
To enable CloudGuard metrics in order to send statuses and statistics collected from HA instances to the Azure Monitor service:
```
enable_custom_metrics = true
```

### Public IP prefix:
To create new public IP prefix for the public IP:
  ```
  use_public_ip_prefix            = true
  create_public_ip_prefix         = true
  ```
To use an existing public IP prefix for the public IP:
  ```
  use_public_ip_prefix            = true
  create_public_ip_prefix         = false
  existing_public_ip_prefix_id    = "public IP prefix resource id"
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
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution. | string | N/A |
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens, and parentheses and cannot end in a period. |
| **cluster_name** | The name of the Check Point Cluster Object. | string | Only alphanumeric characters are allowed, and the name must be 1-30 characters long. |
| **location** | The region where the resources will be deployed at. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`virtual-network`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`public-ip-prefix`<br/>`load-balancer`<br/>`route-table`<br/>`storage-account`<br/>`virtual-machine`<br/>`custom-image`<br/>`availability-set`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | **Defaults:** {} |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images. | string | **Default:** "noCustomUri" |
| **admin_username** | Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used. | string | **Default:** "notused" |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used. | string | "Password";<br />"SSH Public Key"; |
| **admin_password** | The password associated with the local administrator account on each cluster member. | string | Password must have 3 of the following: 1 lowercase character, 1 uppercase character, 1 number, and 1 special character. |
| **admin_SSH_key** | The SSH public key for SSH connections to the instance. Used when the authentication_type is 'SSH Public Key'. | string | **Default:** "" |
| **sic_key** | The Secure Internal Communication one-time secret used to set up trust between the cluster object and the management server. | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long. |
| **serial_console_password_hash** | Optional parameter to enable serial console connection in case of SSH key as authentication type. | string | N/A |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions. | string | N/A |
| **number_of_vm_instances** | Number of VM instances to deploy. | string | **Default:** "2" |
| **vm_size** | Specifies the size of the Virtual Machine. | string | A list of valid VM sizes (e.g., "Standard_D4ds_v5", "Standard_D8ds_v5", etc). |
| **disk_size** | Storage data disk size (GB). | string | A number in the range 100 - 3995 (GB). |
| **os_version** | GAIA OS version. | string | "R8110";<br />"R8120";<br />"R82";<br />"R8210"; |
| **vm_os_sku** | A SKU of the image to be deployed. | string | "sg-byol" - BYOL license;<br />"sg-ngtp" - NGTP PAYG license;<br />"sg-ngtx" - NGTX PAYG license; |
| **vm_os_offer** | The name of the image offer to be deployed. | string | "check-point-cg-r8110";<br />"check-point-cg-r8120";<br />"check-point-cg-r82";<br />"check-point-cg-r8210"; |
| **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point. | boolean| true;<br />false;|
| **admin_shell** | Enables selecting different admin shells. | string | /etc/cli.sh;<br />/bin/bash;<br />/bin/csh;<br />/bin/tcsh;<br />**Default:** "/etc/cli.sh" |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br />"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt" |
| **is_blink** | Define if blink image is used for deployment | boolean | true;<br />false;<br />**Default:** true |
| **enable_custom_metrics** | Indicates whether CloudGuard Metrics will be used for Cluster members monitoring. | boolean | true;<br />false;<br />**Default:** true |
| **availability_type** | Optional parameter, specifies whether to deploy the solution based on Azure Availability Set or Azure Availability Zone. | string | "Availability Zone";<br />"Availability Set";<br />**Default:** "Availability Zone" |
| **availability_zones** | Optional parameter, specifies in which zones to deploy the solution (up to two zones). | list(string) | ["1"];<br />["1", "2"];<br />**Default:**  [] |
| **smart_1_cloud_token_a** | Smart-1 Cloud token to connect automatically ***Member A*** to Check Point's Security Management as a Service. | string | A valid token copied from the Connect Gateway screen in the Smart-1 Cloud portal. |
| **smart_1_cloud_token_b** | Smart-1 Cloud token to connect automatically ***Member B*** to Check Point's Security Management as a Service. | string | A valid token copied from the Connect Gateway screen in the Smart-1 Cloud portal. |
| **vnet_name** | The name of the virtual network that will be created. | string | The name must begin with a letter or number, end with a letter, number, or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| **existing_vnet_resource_group** | The name of the resource group where the Virtual Network is located. Required when using an existing Virtual Network. | string | **Default:** "" |
| **frontend_subnet_name** | The Virtual Network subnet name for the frontend interface. | string | N/A |
| **backend_subnet_name** | The Virtual Network subnet name for the backend interface. | string | N/A |
| **address_space** | The address prefixes of the virtual network. | string | Valid CIDR block<br />**Default:** "10.0.0.0/16" |
| **subnet_prefixes** | The address prefixes to be used for created subnets. | string | The subnets need to contain within the address space for this virtual network (defined by the `address_space` variable).<br />**Default:** ["10.0.0.0/24", "10.0.1.0/24"] |
| **nsg_id** | Optional ID for a Network Security Group that already exists in Azure. If not provided, a default NSG will be created. | string | Existing NSG resource ID<br />**Default:** "" |
| **storage_account_deployment_mode** | Choose the boot diagnostics storage account type. | string | New;<br/> Existing;<br/> Managed;<br/> None;<br/> **Default:** New |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | boolean| true;<br />false;<br />**Default:** false |
| **storage_account_additional_ips** | IPs/CIDRs that are allowed access to the Storage Account.<br/> Relevant only if `storage_account_deployment_mode = "New"`. | list(string) | A list of valid IPs and CIDRs<br />**Default:** [] |
| **existing_storage_account_name** | The existing storage account name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **existing_storage_account_resource_group_name** | The existing storage account resource group name.<br/> Relevant only if `storage_account_deployment_mode = "Existing"`. | string | **Default:** "" |
| **sku** | SKU | string | **Default:** "Standard" |
| **security_rules** | Security rules for the Network Security Group. | list(any) | A security rule composed of: {name, priority, direction, access, protocol, source_port_ranges, destination_port_ranges, source_address_prefix, destination_address_prefix, description}<br />**Default:** [] |
| **vips_names** | Names for additional Virtual IP addresses beyond the primary cluster VIP. Each name creates a corresponding public IP resource. | list(string) | **Default:** [] |
| **lb_probe_name** | Name to be used for lb health probe. | string | **Default:** "health_prob_port" |
| **lb_probe_port** | Port to be used for load balancer health probes and rules. | string | **Default:** "8117" |
| **lb_probe_protocol** | Protocols to be used for load balancer health probes and rules. | string | **Default:** "Tcp" |
| **lb_probe_unhealthy_threshold** | Number of times load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy. | number | **Default:** 2 |
| **lb_probe_interval** | Interval in seconds load balancer health probe rule perfoms a check. | number | **Default:** 5 |
| **enable_floating_ip** | Indicates whether the load balancers will be deployed with floating IP. | boolean | true;<br />false;<br />**Default:** true |
| **use_public_ip_prefix** | Indicates whether the public IP resources will be deployed with public IP prefix. | boolean | true;<br />false;<br />**Default:** false |
| **create_public_ip_prefix** | Indicates whether the public IP prefix will be created or an existing one will be used. | boolean | true;<br />false;<br />**Default:** false |
| **existing_public_ip_prefix_id** | The existing public IP prefix resource ID. | string | Existing public IP prefix resource ID.<br />**Default:** "" |