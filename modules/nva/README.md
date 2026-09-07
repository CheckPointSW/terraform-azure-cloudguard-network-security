# Check Point CloudGuard Virtual WAN Module
This Terraform module deploys Check Point CloudGuard Network Security Virtual WAN NVA solution in Azure.
As part of the deployment the following resources are created:
- Resource groups
- Virtual WAN
- Virtual WAN Hub
- Azure Managed Application:
  - NVA
  - Managed identity

For additional information,
please see the [CloudGuard Network for Azure Virtual WAN Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_Azure_vWAN/Default.htm)

## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest).

**Authentication:** choose your preferred login method to Azure before deploying:
1. **Using Service Principal** - set `authentication_method = "Service Principal"` and provide `client_id`/`client_secret`, as shown below.
2. **Using Azure CLI / Managed Identity / `ARM_*` environment variables** - set `authentication_method = "Azure CLI"`, run `az login`, and omit `client_id`/`client_secret` entirely.

**Example:**
```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/nva"
  version = "~> 1.0"

  # Authentication with Service Principal
  authentication_method = "Service Principal"
  client_secret         = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id             = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id             = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  subscription_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Basic Configurations Variables
  resource_group_name = "tf-managed-app-resource-group"
  location            = "westcentralus"
  tags                = {}

  # Virtual WAN Configurations Variables
  vwan_name               = "tf-vwan"
  vwan_hub_name           = "tf-vwan-hub"
  vwan_hub_address_prefix = "10.0.0.0/16"

  # Network Virtual Appliance Configurations Variables
  managed_app_name                = "tf-vwan-managed-app-nva"
  nva_rg_name                     = "tf-vwan-nva-rg"
  nva_name                        = "tf-vwan-nva"
  os_version                      = "R82"
  license_type                    = "Security Enforcement (NGTP)"
  scale_unit                      = "2"
  bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
  admin_shell                     = "/etc/cli.sh"
  sic_key                         = "xxxxxxxxxxxx"
  admin_SSH_key                   = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
  maintenance_mode_password_hash  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  serial_console_password_hash    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  bgp_asn                         = "64512"
  custom_metrics                  = "yes"
  upgrade                         = "no"
  routing_intent_internet_traffic = "yes"
  routing_intent_private_traffic  = "yes"
  existing_public_ip              = ""
  new_public_ip                   = "yes"
}
```

## Conditional Creation
### New or Existing Virtual WAN Deployment:
You can define if you want to deploy the NVA along side a new Virtual WAN or to use an existing Virtual WAN.
- To create a new VWAN, specify the `vwan_hub_address_prefix` variable:
  ```
  vwan_name               = "tf-vwan"
  vwan_hub_name           = "tf-vwan-hub"
  vwan_hub_address_prefix = "10.0.0.0/16"
  ```
- To deploy using an existing Virtual WAN, leave the `vwan_hub_address_prefix` empty:
  ```
  vwan_hub_name           = "tf-vwan-hub"
  vwan_hub_resource_group = "tf-vwan-hub-resource-group-name"
  vwan_hub_address_prefix = ""
  ```

## Module's variables:
| Name | Description | Type | Allowed values | Default | Required |
|------|-------------|------|----------------|---------|----------|
| **authentication_method** | The authentication method used to deploy the solution. | string | "Service Principal";<br/>"Azure CLI"; | N/A | Yes |
| **subscription_id** | The subscription ID is used to pay for Azure cloud services. | string | N/A | N/A | Yes |
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution. | string | N/A | N/A | Yes |
| **client_id** | The client ID of the Service Principal used to deploy the solution. Required only when `authentication_method = "Service Principal"`; otherwise leave unset to authenticate via Azure CLI, Managed Identity, or `ARM_*` environment variables. | string | N/A | null | No |
| **client_secret** | The client secret value of the Service Principal used to deploy the solution. Required only when `authentication_method = "Service Principal"`; otherwise leave unset to authenticate via Azure CLI, Managed Identity, or `ARM_*` environment variables. | string | N/A | null | No |
| **resource_group_name** | The name of the resource group that will contain the managed application. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period. | N/A | Yes |
| **location** | The region where the resources will be deployed at. | string | The full list of supported Azure regions can be found at https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-locations-partners#locations. | N/A | Yes |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group` (Applies tags to managed application resource group)<br/>`virtual-wan`<br/>`virtual-hub`<br/>`managed-identity` (Applies tags to the managed identity of the managed application)<br/>`managed-application`<br/>`network-virtual-appliance`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | N/A | {} | No |
| **vwan_name** | The name of the virtual WAN that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. | "tf-vwan" | No |
| **vwan_hub_name** | The name of the virtual WAN hub that will be created, or the name of the Virtual WAN hub inside an existing Virtual WAN. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. | "tf-vwan-hub" | No |
| **vwan_hub_resource_group** | The resource group name for the Virtual Hub when using an existing VWAN. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. | "" | No |
| **vwan_hub_address_prefix** | The address prefixes of the virtual WAN hub, used to determine whether to deploy a new Virtual WAN or use an existing Virtual WAN. | string | Valid CIDR block, or an empty string in case you want to use an existing Virtual WAN | "10.0.0.0/16" | No |
| **managed_app_name** | The name of the managed application that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. | "tf-vwan-managed-app" | No |
| **nva_rg_name** | The name of the resource group that will contain the NVA. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period. | "tf-vwan-nva-rg" | No |
| **nva_name** | The name of the NVA that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. | "tf-vwan-nva" | No |
| **os_version** | The GAIA os version. | string | "R8110";<br/>"R8120";<br/>"R82";<br/>"R8210"; | "R82" | No |
| **license_type** | The Check Point licence type. | string | "Security Enforcement (NGTP)";<br/>"Full Package (NGTX and Smart-1 Cloud)";<br/>"Full Package Premium (NGTX and Smart-1 Cloud Premium)". | "Security Enforcement (NGTP)" | No |
| **scale_unit** | The scale unit determines the size and number of resources deployed. The higher the scale unit, the greater the amount of traffic that can be handled. | string | "2";<br/>"4";<br/>"10";<br/>"20";<br/>"30";<br/>"60";<br/>"80"; | "2" | No |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt".<br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it. | "" | No |
| **admin_shell** | Enables to select different admin shells. | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh. | "/etc/cli.sh" | No |
| **sic_key** | The Secure Internal Communication one time secret used to set up trust between the gateway object and the management server. | string | Only alphanumeric characters are allowed, and the value must be 8-30 characters long. | "" | No |
| **admin_SSH_key** | The public ssh key used for ssh connection to the NVA GW instances. | string | ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx generated-by-azure. | "" | No |
| **serial_console_password_hash** | (Optional) Password hash for serial console connection. Relevant when using SSH Public Key authentication. | string | N/A | "" | No |
| **maintenance_mode_password_hash** | (Optional) Maintenance mode password hash, relevant only for R81.20 and higher versions. | string | N/A | "" | No |
| **bgp_asn** | The BGP autonomous system number. | string | A number in the range 64512-65534, excluding 65515 and 65520. | "64512" | No |
| **custom_metrics** | Indicates whether CloudGuard Metrics will be used for gateway monitoring. | string | yes;<br/>no; | "yes" | No |
| **upgrade** | Indicates whether this deployment is an upgrade of an existing CloudGuard NVA. Set to "yes" during a side-by-side upgrade. | string | yes;<br/>no; | "no" | No |
| **routing_intent_internet_traffic** | Set routing intent policy to allow internet traffic through the new nva. | string | yes;<br/>no.<br/>Please verify routing-intent is configured successfully post-deployment. | "yes" | No |
| **routing_intent_private_traffic** | Set routing intent policy to allow private traffic through the new nva. | string | yes;<br/>no.<br/>Please verify routing-intent is configured successfully post-deployment. | "yes" | No |
| **existing_public_ip** | Existing public IP resource to attach to the newly deployed NVA. | string | A resource ID of the public IP resource. Required when new_public_ip is "no"; must be empty when new_public_ip is "yes". | "" | No |
| **new_public_ip** | Deploy a new public IP resource as part of the managed app and attach to the NVA. | string | yes — create a new public IP (existing_public_ip must be empty);<br/>no — use existing_public_ip (must be provided); | "no" | No |
