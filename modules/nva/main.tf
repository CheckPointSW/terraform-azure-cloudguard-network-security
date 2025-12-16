//********************** Basic Configuration **************************//
resource "azurerm_resource_group" "managed_app_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = merge(lookup(var.tags, "resource-group", {}), lookup(var.tags, "all", {}))
}

//********************** Virtual WAN **************************//
module "vwan" {
  source                  = "../common/vwan"
  vwan_name               = var.vwan_name
  vwan_hub_name           = var.vwan_hub_name
  vwan_hub_address_prefix = var.vwan_hub_address_prefix
  vwan_hub_resource_group = var.vwan_hub_resource_group
  resource_group_name     = azurerm_resource_group.managed_app_rg.name
  location                = azurerm_resource_group.managed_app_rg.location
  tags                    = var.tags
}

//********************** Image Version **************************//
data "external" "az_access_token" {
  count   = var.authentication_method == "Azure CLI" ? 1 : 0
  program = ["az", "account", "get-access-token", "--resource=https://management.azure.com", "--query={accessToken: accessToken}", "--output=json"]
}

data "http" "azure_auth" {
  count  = var.authentication_method == "Service Principal" ? 1 : 0
  url    = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/token"
  method = "POST"
  request_headers = {
    "Content-Type" = "application/x-www-form-urlencoded"
  }
  request_body = "grant_type=client_credentials&client_id=${var.client_id}&client_secret=${var.client_secret}&scope=https://management.azure.com/.default"
}

locals {
  access_token = var.authentication_method == "Service Principal" ? jsondecode(data.http.azure_auth[0].response_body).access_token : data.external.az_access_token[0].result.accessToken
}

data "http" "image_versions" {
  method = "GET"
  url    = "https://management.azure.com/subscriptions/${var.subscription_id}/providers/Microsoft.Network/networkVirtualApplianceSKUs/checkpoint${local.license_types[var.license_type]}?api-version=2020-05-01"
  request_headers = {
    Accept          = "application/json"
    "Authorization" = "Bearer ${local.access_token}"
  }
}

locals {
  image_versions = tolist([for version in jsondecode(data.http.image_versions.response_body).properties.availableVersions : version if substr(version, 0, 4) == substr(lower(length(var.os_version) > 3 ? var.os_version : "${var.os_version}00"), 1, 4)])

  routing_intent_internet_policy = {
    "name" : "InternetTraffic",
    "destinations" : [
      "Internet"
    ],
    "nextHop" : "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva_rg_name}/providers/Microsoft.Network/networkVirtualAppliances/${var.nva_name}"
  }

  routing_intent_private_policy = {
    "name" : "PrivateTrafficPolicy",
    "destinations" : [
      "PrivateTraffic"
    ],
    "nextHop" : "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva_rg_name}/providers/Microsoft.Network/networkVirtualAppliances/${var.nva_name}"
  }

  routing_intent_policies  = var.routing_intent_internet_traffic == "yes" ? (var.routing_intent_private_traffic == "yes" ? tolist([local.routing_intent_internet_policy, local.routing_intent_private_policy]) : tolist([local.routing_intent_internet_policy])) : (var.routing_intent_private_traffic == "yes" ? tolist([local.routing_intent_private_policy]) : [])
  public_ip_resource_group = "/subscriptions/${var.subscription_id}/resourceGroups/${var.new_public_ip == "yes" ? azurerm_resource_group.managed_app_rg.name : var.existing_public_ip != "" ? split("/", var.existing_public_ip)[4] : ""}"

}

//********************** Marketplace Terms & Solution Registration **************************//
data "http" "accept_marketplace_terms_existing_agreement" {
  method = "GET"
  url    = "https://management.azure.com/subscriptions/${var.subscription_id}/providers/Microsoft.MarketplaceOrdering/agreements/checkpoint/offers/cp-vwan-managed-app/plans/vwan-app?api-version=2021-01-01"
  request_headers = {
    Accept          = "application/json"
    "Authorization" = "Bearer ${local.access_token}"
  }
}

resource "azurerm_marketplace_agreement" "accept_marketplace_terms" {
  count     = can(jsondecode(data.http.accept_marketplace_terms_existing_agreement.response_body).id) ? (jsondecode(data.http.accept_marketplace_terms_existing_agreement.response_body).properties.state == "Active" ? 0 : 1) : 1
  publisher = "checkpoint"
  offer     = var.plan_product
  plan      = "vwan-app"
}


data "http" "azurerm_resource_provider_registration_exist" {
  method = "GET"
  url    = "https://management.azure.com/subscriptions/${var.subscription_id}/providers/Microsoft.Solutions?api-version=2021-01-01"
  request_headers = {
    Accept          = "application/json"
    "Authorization" = "Bearer ${local.access_token}"
  }
}

resource "azurerm_resource_provider_registration" "solutions" {
  count = jsondecode(data.http.azurerm_resource_provider_registration_exist.response_body).registrationState == "Registered" ? 0 : 1
  name  = "Microsoft.Solutions"
}

//********************** Managed Identity **************************//
resource "azurerm_user_assigned_identity" "managed_app_identity" {
  location            = azurerm_resource_group.managed_app_rg.location
  name                = "managed_app_identity"
  resource_group_name = azurerm_resource_group.managed_app_rg.name
  tags                = merge(lookup(var.tags, "managed-identity", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_role_assignment" "reader" {
  depends_on           = [azurerm_user_assigned_identity.managed_app_identity]
  scope                = module.vwan.hub_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.managed_app_identity.principal_id
}

resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.managed_app_rg.name
  }
  byte_length = 8
}

resource "azurerm_role_definition" "public_ip_join_role" {
  count = var.new_public_ip == "yes" || length(var.existing_public_ip) > 0 ? 1 : 0
  name  = "Managed Application Public IP Join Role - ${random_id.random_id.hex}"
  scope = local.public_ip_resource_group
  permissions {
    actions     = ["Microsoft.Network/publicIPAddresses/join/action"]
    not_actions = []
  }
  assignable_scopes = [local.public_ip_resource_group]
}

resource "azurerm_role_assignment" "public_ip_join_role_assignment" {
  count              = var.new_public_ip == "yes" || length(var.existing_public_ip) > 0 ? 1 : 0
  scope              = local.public_ip_resource_group
  role_definition_id = azurerm_role_definition.public_ip_join_role[0].role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.managed_app_identity.principal_id
}

//********************** Managed Application Configuration **************************//
resource "azapi_resource" "managed_app" {
  depends_on = [
    azurerm_marketplace_agreement.accept_marketplace_terms,
    azurerm_resource_provider_registration.solutions
  ]
  type      = "Microsoft.Solutions/applications@2019-07-01"
  name      = var.managed_app_name
  location  = azurerm_resource_group.managed_app_rg.location
  parent_id = azurerm_resource_group.managed_app_rg.id
  body = {
    kind = "MarketPlace",
    plan = {
      name      = "vwan-app"
      product   = var.plan_product
      publisher = "checkpoint"
      version   = var.plan_version
    },
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        (azurerm_user_assigned_identity.managed_app_identity.id) = {}
      }
    },
    properties = {
      parameters = {
        location = {
          value = azurerm_resource_group.managed_app_rg.location
        },
        hubId = {
          value = module.vwan.hub_id
        },
        osVersion = {
          value = var.os_version
        },
        LicenseType = {
          value = var.license_type
        },
        imageVersion = {
          value = element(local.image_versions, length(local.image_versions) - 1)
        },
        scaleUnit = {
          value = var.scale_unit
        },
        bootstrapScript = {
          value = var.bootstrap_script
        },
        adminShell = {
          value = var.admin_shell
        },
        sicKey = {
          value = var.sic_key
        },
        sshPublicKey = {
          value = var.admin_SSH_key
        },
        MaintenanceModePasswordHash = {
          value = var.maintenance_mode_password_hash
        },
        SerialConsolePasswordHash = {
          value = var.serial_console_password_hash
        },
        BGP = {
          value = var.bgp_asn
        },
        NVA = {
          value = var.nva_name
        },
        customMetrics = {
          value = var.custom_metrics
        },
        hubASN = {
          value = module.vwan.hub_virtual_router_asn
        },
        hubPeers = {
          value = module.vwan.hub_virtual_router_ips
        },
        smart1CloudTokenA = {
          value = var.smart1_cloud_token_a
        },
        smart1CloudTokenB = {
          value = var.smart1_cloud_token_b
        },
        smart1CloudTokenC = {
          value = var.smart1_cloud_token_c
        },
        smart1CloudTokenD = {
          value = var.smart1_cloud_token_d
        },
        smart1CloudTokenE = {
          value = var.smart1_cloud_token_e
        },
        publicIPIngress = {
          value = (var.new_public_ip == "yes" || length(var.existing_public_ip) > 0) ? "yes" : "no"
        },
        createNewIPIngress = {
          value = var.new_public_ip
        },
        ipIngressExistingResourceId = {
          value = var.existing_public_ip
        },
        templateName = {
          value = "wan_terraform_registry"
        },
        tags = {
          value = {
            "Microsoft.Network/networkVirtualAppliances" = merge(lookup(var.tags, "network-virtual-appliance", {}), lookup(var.tags, "all", {}))
          }
        },
        customLicenseType = {
          value = var.custom_license_type
        }
      },
      managedResourceGroupId = "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva_rg_name}"
    }
  }

  tags = merge(lookup(var.tags, "managed-application", {}), lookup(var.tags, "all", {}))
}

//********************** Routing Intent **************************//
resource "azapi_resource" "routing_intent" {
  depends_on = [
    azapi_resource.managed_app
  ]
  count     = length(local.routing_intent_policies) != 0 ? 1 : 0
  type      = "Microsoft.Network/virtualHubs/routingIntent@2024-05-01"
  name      = "hubRoutingIntent"
  parent_id = module.vwan.hub_id

  body = {
    properties = {
      routingPolicies = local.routing_intent_policies
    }
  }

  tags = merge(lookup(var.tags, "routing-intent", {}), lookup(var.tags, "all", {}))
}
