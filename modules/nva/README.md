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

**Example:**
```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/nva"
  version = "~> 1.0"

  # Authentication Variables
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
  routing_intent_internet_traffic = "yes"
  routing_intent_private_traffic  = "yes"
  existing_public_ip              = ""
  new_public_ip                   = "yes"

  # Smart-1 Cloud Configurations Variables
  smart1_cloud_token_a = ""
  smart1_cloud_token_b = ""
  smart1_cloud_token_c = ""
  smart1_cloud_token_d = ""
  smart1_cloud_token_e = ""
}
```

## Conditional Creation
### New or Existing Virtual WAN Deployment:
You can define if you want to deploy the NVA along side a new Virtual WAN or to use an existing Virtual WAN.
- To create a new VWAN, specify the `vwan_hub_address_prefix` variable:
  ```
  vwan_name               = "tf-vwan"
  vwan_hub_name           = "tf-vwan-hub"
  vwan_hub_address_prefix = "10.0.0.0/16
  ```
- To deploy using an existing Virtual WAN, leave the `vwan_hub_address_prefix` empty:
  ```
  vwan_hub_name           = "tf-vwan-hub"
  vwan_hub_resource_group = "tf-vwan-hub-resource-group-name"
  vwan_hub_address_prefix = ""
  ```

## Module's variables:
| Name | Description | Type | Allowed values |
|------|-------------|------|----------------|
| **authentication_method** | The authentication method used to deploy the solution. | string | "Service Principal";<br/>"Azure CLI"; |
| **subscription_id** | The subscription ID is used to pay for Azure cloud services. | string | N/A |
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution. | string | N/A |
| **client_id** | The client ID of the Service Principal used to deploy the solution. | string | N/A |
| **client_secret** | The client secret value of the Service Principal used to deploy the solution. | string | N/A |
| **resource_group_name** | The name of the resource group that will contain the managed application. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period.<br/>**Default:** "managed-app-resource-group" |
| **location** | The region where the resources will be deployed at. | string | The full list of supported Azure regions can be found at https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-locations-partners#locations.<br/>**Default:** "westcentralus" |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group` (Applies tags to managed application resource group)<br/>`virtual-wan`<br/>`virtual-hub`<br/>`managed-identity` (Applies tags to the managed identity of the managed application)<br/>`managed-application`<br/>`routing-intent`<br/>`network-virtual-appliance`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | **Defaults:** {} |
| **vwan_name** | The name of the virtual WAN that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens.<br/>**Default:** "tf-vwan" |
| **vwan_hub_name** | The name of the virtual WAN hub that will be created, or the name of the Virtual WAN hub inside an existing Virtual WAN. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens.<br/>**Default:** "tf-vwan-hub" |
| **vwan_hub_resource_group** | The resource group name for the Virtual Hub when using an existing VWAN. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens.<br/>**Default:** "tf-vwan-hub" |
| **vwan_hub_address_prefix** | The address prefixes of the virtual WAN hub, used for determining if deploying an new Virtual WAN or an existing Virtual WAN. | string | Valid CIDR block, or an empty string in case you want to use an existing Virtual WAN<br/>**Default:** "10.0.0.0/16" |
| **managed_app_name** | The name of the managed application that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens.<br/>**Default:** tf-vwan-managed-app |
| **nva_rg_name** | The name of the resource group that will contain the NVA. | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period.<br/>**Default:** tf-vwan-nva-rg |
| **nva_name** | The name of the NVA that will be created. | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens.<br/>**Default:** tf-vwan-nva |
| **os_version** | The GAIA os version. | string | "R8110";<br/>"R8120";<br/>"R82";<br/>**Default:** "R82" |
| **license_type** | The Check Point licence type. | string | "Security Enforcement (NGTP)";<br/>"Full Package (NGTX and Smart1-Cloud)";<br/>"Full Package Premium (NGTX and Smart1-Cloud Premium)".<br/>**Default:** "Security Enforcement (NGTP)" |
| **scale_unit** | The scale unit determines the size and number of resources deployed. The higher the scale unit, the greater the amount of traffic that can be handled. | string | "2";<br/>"4";<br/>"10";<br/>"20";<br/>"30";<br/>"60";<br/>"80";<br/>**Default:** "2" |
| **bootstrap_script** | An optional script to run on the initial boot. | string | Bootstrap script example:<br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt".<br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it.<br/>**Default:** "" |
| **admin_shell** | Enables to select different admin shells. | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh.<br/>**Default:** "/etc/cli.sh" |
| **sic_key** | The Secure Internal Communication one time secret used to set up trust between the gateway object and the management server. | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long. |
| **admin_SSH_key** | The public ssh key used for ssh connection to the NVA GW instances. | string | ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx generated-by-azure. |
| **serial_console_password_hash** | Optional parameter, used to enable serial console connection. In R81.10 and below, the serial console password is also used as the maintenance mode password. To generate password hash use the command `openssl passwd -6 PASSWORD` on Linux.<br/>**Note:** In Azure Virtual Wan there is currently no serial console on the Network Virtual Appliance, the serial console password will be used as a maintenance mode password in R81.10 and below. | string | N/A |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions. To generate a password hash, use the command `grub2-mkpasswd-pbkdf2` on Linux. | string | N/A |
| **bgp_asn** | The BGP autonomous system number. | string | 64512.<br/>**Default:** "64512" |
| **custom_metrics** | Indicates whether CloudGuard Metrics will be use for gateway monitoring. | string | yes;<br/>no;<br/>**Default:** "yes" |
| **routing_intent_internet_traffic** | Set routing intent policy to allow internet traffic through the new nva. | string | yes;<br/>no.<br/>Please verify routing-intent is configured successfully post-deployment.<br/>**Default:** "yes" |
| **routing_intent_private_traffic** | Set routing intent policy to allow private traffic through the new nva. | string | yes;<br/>no.<br/>Please verify routing-intent is configured successfully post-deployment.<br/>**Default:** "yes" |
| **existing_public_ip** | Existing public IP reosurce to attach to the newly deployed NVA. | string | A resource ID of the public IP resource. |
| **new_public_ip** | Deploy a new public IP resource as part of the managed app and attach to the NVA. | string | yes;<br/>no;<br/>**Defaults:** "no" |
| **smart1_cloud_token_a** | Smart-1 Cloud token to connect automatically ***NVA instance a*** to Check Point's Security Management as a Service.<br/><br/>Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501). | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. |
| **smart1_cloud_token_b** | Smart-1 Cloud token to connect automatically ***NVA instance b*** to Check Point's Security Management as a Service.<br/><br/>Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501). | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. |
| **smart1_cloud_token_c** | Smart-1 Cloud token to connect automatically ***NVA instance c*** to Check Point's Security Management as a Service.<br/><br/>Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501). | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. |
| **smart1_cloud_token_d** | Smart-1 Cloud token to connect automatically ***NVA instance d*** to Check Point's Security Management as a Service.<br/><br/>Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501). | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. |
| **smart1_cloud_token_e** | Smart-1 Cloud token to connect automatically ***NVA instance e*** to Check Point's Security Management as a Service.<br/><br/>Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501). | string | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal. |