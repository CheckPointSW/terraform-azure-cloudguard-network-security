# Check Point CloudGuard Management Module - Existing VNet

This Terraform module deploys Check Point CloudGuard Network Security Management solution into an existing VNet in azure.
As part of the deployment the following resources are created:
- Resource group
- Network security group
- Virtual Machine
- System assigned identity

This solution uses the following modules:
- common - used for creating a resource group and defining common variables.
- network_security_group - used for creating new network security groups and rules.


## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest).

**Example:**
```
provider "azurerm" {
  features {}
}

module "example_module" {

        source  = "CheckPointSW/cloudguard-network-security/azure//modules/management_existing_vnet"
        version = "1.0.8"

        source_image_vhd_uri            = "noCustomUri"
        resource_group_name             = "checkpoint-mgmt-terraform"
        mgmt_name                       = "checkpoint-mgmt-terraform"
        location                        = "eastus"
        vnet_name                       = "checkpoint-mgmt-vnet"
        vnet_resource_group             = "existing-vnet"
        management_subnet_name          = "mgmt-subnet"
        subnet_1st_Address              = "10.0.1.4"
        management_GUI_client_network   = "0.0.0.0/0"
        mgmt_enable_api                 = "disable"
        admin_password                  = "xxxxxxxxxxxx"
        vm_size                         = "Standard_D4ds_v5"
        disk_size                       = "110"
        vm_os_sku                       = "mgmt-byol"
        vm_os_offer                     = "check-point-cg-r82"
        os_version                      = "R82"
        bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
        allow_upload_download           = true
        authentication_type             = "Password"
        admin_shell                     = "/etc/cli.sh"
        serial_console_password_hash    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        maintenance_mode_password_hash  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        nsg_id                          = ""
        add_storage_account_ip_rules    = false
        storage_account_additional_ips  = []
}
```
  

### Module's variables:

| Name | Description | Type | Allowed values |
|------|-------------|------|----------------|
| **tenant_id** | The tenant ID of the Service Principal used to deploy the solution | string | |
| **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images | string | **Default:** "noCustomUri" |
| **resource_group_name** | The name of the resource group that will contain the contents of the deployment | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period. |
| **mgmt_name** | Management name | string | |
| **location** | The region where the resources will be deployed at | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions. |
| **vnet_name** | Virtual Network name | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens. |
| **vnet_resource_group** | Resource Group of the existing virtual network | string | The exact name of the existing vnet's resource group. |
| **management_subnet_name** | Management subnet name | string | The exact name of the existing subnet. |
| **subnet_1st_Address** | The first available address of the subnet | string | |
| **management_GUI_client_network** | Allowed GUI clients - GUI clients network CIDR | string | |
| **mgmt_enable_api** | Enable api access to the management | string | "all";<br/>"management_only";<br/>"gui_clients";<br/>"disable".<br/>**Default:** "disable" |
| **admin_password** | The password associated with the local administrator account on each cluster member | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character. |
| **vm_size** | Specifies the size of Virtual Machine | string | "Standard_F2s", "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s", "Standard_F2", "Standard_F4", "Standard_F8", "Standard_F16", "Standard_D2_v5", "Standard_D4_v5", "Standard_D8_v5", "Standard_D16_v5","Standard_D32_v5", "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5", "Standard_D2d_v5", "Standard_D4d_v5", "Standard_D8d_v5", "Standard_D16d_v5", "Standard_D32d_v5", "Standard_D2ds_v5", "Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5". |
| **disk_size** | Storage data disk size size(GB) | string | A number in the range 100 - 3995 (GB). |
| **vm_os_sku** | A sku of the image to be deployed | string | "mgmt-byol" - BYOL license;<br/>"mgmt-25" - PAYG. |
| **vm_os_offer** | The name of the image offer to be deployed | string | "check-point-cg-r8110";<br/>"check-point-cg-r8120";<br/>"check-point-cg-r82". |
| **os_version** | GAIA OS version | string | "R8110";<br/>"R8120";<br/>"R82". |
| **bootstrap_script** | An optional script to run on the initial boot | string | Bootstrap script example:<br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt".<br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it.<br/>**Default:** "" |
| **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | boolean | true;<br/>false. |
| **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used | string | "Password";<br/>"SSH Public Key". |
| **admin_shell** | Enables to select different admin shells | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh.<br/>**Default:** "/etc/cli.sh" |
| **serial_console_password_hash** | Optional parameter, used to enable serial console connection in case of SSH key as authentication type, to generate password hash use the command 'openssl passwd -6 PASSWORD' on Linux and paste it here | string | |
| **maintenance_mode_password_hash** | Maintenance mode password hash, relevant only for R81.20 and higher versions, to generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here | string | |
| **nsg_id** | Optional ID for a Network Security Group that already exists in Azure, if not provided, will create a default NSG | string | Existing NSG resource ID.<br/>**Default:** "" |
| **add_storage_account_ip_rules** | Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location, if false then accses will be allowed from all networks | boolean | true;<br/>false.<br/>**Default:** false |
| **storage_account_additional_ips** | IPs/CIDRs that are allowed access to the Storage Account | list(string) | A list of valid IPs and CIDRs.<br/>**Default:** [] |
| **tags** | Tags can be associated either globally across all resources or scoped to specific resource types. For example, a global tag can be defined as: {"all": {"example": "example"}}.<br/>Supported resource types for tag assignment include:<br>`all` (Applies tags universally to all resource instances)<br/>`resource-group`<br/>`network-security-group`<br/>`network-interface`<br/>`public-ip`<br/>`storage-account`<br/>`virtual-machine`<br/>`custom-image`<br/>**Important:** When identical tag keys are defined both globally under `all` and within a specific resource scope, the tag value specified under `all` overrides the resource-specific tag. | map(map(string)) | {} |