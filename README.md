![GitHub Wachers](https://img.shields.io/github/watchers/CheckPointSW/terraform-azure-cloudguard-network-security)
![GitHub Release](https://img.shields.io/github/v/release/CheckPointSW/terraform-azure-cloudguard-network-security)
![GitHub Commits Since Last Commit](https://img.shields.io/github/commits-since/CheckPointSW/terraform-azure-cloudguard-network-security/latest/master)
![GitHub Last Commit](https://img.shields.io/github/last-commit/CheckPointSW/terraform-azure-cloudguard-network-security/master)
![GitHub Repo Size](https://img.shields.io/github/repo-size/CheckPointSW/terraform-azure-cloudguard-network-security)
![GitHub Downloads](https://img.shields.io/github/downloads/CheckPointSW/terraform-azure-cloudguard-network-security/total)

# Terraform Modules for CloudGuard Network Security (CGNS) - Azure


## Introduction
This repository provides a structured set of Terraform modules for deploying Check Point CloudGuard Network Security in Microsoft Azure. These modules automate the creation of Virtual Networks, Security Gateways, High-Availability architectures, and more, enabling secure and scalable cloud deployments.

## Repository Structure
`Submodules:` Contains modular, reusable, production-grade Terraform components, each with its own documentation.

`Examples:` Demonstrates how to use the modules.

 
**Submodules:**
* [`high-availability`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/high-availability) - Deploys CloudGuard High Availability solution.
* [`management`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/management) - Deploys CloudGuard Management solution.
* [`mds`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/mds) - Deploys CloudGuard Multi-Domain Security Management solution.
* [`nva`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/nva) - Deploys CloudGuard Virtual WAN NVA solution.
* [`single-gateway`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/single-gateway) - Deploys CloudGuard Single Gateway solution.
* [`vmss`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/vmss) - Deploys CloudGuard VMSS solution.

Internal Submodules:
* [`common`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/common) - Contains shared configurations and reusable components for all modules.
* [`custom-image`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/custom-image) - Manages custom image configurations.
* [`network-security-group`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/network-security-group) - Manages Network Security Groups (NSGs) with CloudGuard-specific rules.
* [`storage-account`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/storage-account) - Manages storage account configurations.
* [`vnet`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/vnet) - Simplifies Virtual Network and subnet configurations.
* [`vwan`](https://registry.terraform.io/modules/CheckPointSW/cloudguard-network-security/azure/latest/submodules/vwan) - Manages Virtual WAN configurations.


## Security Rules Default Configuration
Some modules in this repository include default security rules configured for "allow all inbound traffic." These rules are provided for ease of deployment but are not intended for production use without further customization. Add security rule to override the default "allow all traffic" configuration.

**Example:** To restrict inbound traffic, update the security_rules attribute in the submodule configuration:
```hcl
security_rules = [
  {
    name                       = "AllowSSH"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_ranges         = "*"
    destination_port_ranges    = "22"
    description                = "Allow SSH inbound connections"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
]
```

**Check Point Recommendation:** Always follow the principle of least privilege when configuring security rules to reduce exposure to threats.

***

# Best Practices for Using CloudGuard Modules

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) version 1.9 or higher
- Azure Service Principal with required permissions (see [Required Permissions](#required-permissions) below)

---

## Deployment Steps

### 1. Configure Your Terraform Module
Create a `main.tf` file with the required module and **mandatory authentication variables**:

```hcl
provider "azurerm" {
  features {}
}

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/azure//modules/{module_name}"
  version = "~> 1.0"

  # Authentication Variables (Required)
  client_secret   = "<your-client-secret>"
  client_id       = "<your-client-id>"
  tenant_id       = "<your-tenant-id>"
  subscription_id = "<your-subscription-id>"

  # Add additional module-specific variables here
}
```

**Important:** All four authentication variables (`client_secret`, `client_id`, `tenant_id`, `subscription_id`) are mandatory for all modules.

---

### 2. Initialize and Deploy
Run the following Terraform commands to deploy your resources:

```bash
# Initialize Terraform and download providers
terraform init

# Preview the changes
terraform plan

# Apply the configuration
terraform apply
```

---
 
## Required Permissions

The Azure Service Principal used for authentication must have the following permissions:

- **Contributor** role - for creating and managing Azure resources
- **User Access Administrator** role - for role assignments (required for VMSS deployments)
- For additional roles and permissions, see [Azure Built-in Roles](https://learn.microsoft.com/he-il/azure/role-based-access-control/built-in-roles)

For detailed information on creating a Service Principal and assigning roles, refer to:
- [Azure Service Principal Documentation](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal)
- [Azure RBAC Role Assignments](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
- [Terraform Azure Provider Authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)

---
