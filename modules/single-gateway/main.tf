//********************** Basic Configuration **************************//
module "common" {
  source                         = "../common/common"
  resource_group_name            = var.resource_group_name
  location                       = var.location
  is_zonal                       = var.zone != ""
  availability_zones_num         = "1"
  availability_zones             = var.zone == "" ? [] : [var.zone]
  admin_password                 = var.admin_password
  installation_type              = var.installation_type
  module_name                    = local.module_name
  module_version                 = local.module_version
  number_of_vm_instances         = 1
  allow_upload_download          = var.allow_upload_download
  vm_size                        = var.vm_size
  disk_size                      = var.disk_size
  os_version                     = var.os_version
  vm_os_sku                      = var.vm_os_sku
  vm_os_offer                    = var.vm_os_offer
  is_blink                       = var.is_blink
  authentication_type            = var.authentication_type
  serial_console_password_hash   = var.serial_console_password_hash
  maintenance_mode_password_hash = var.maintenance_mode_password_hash
  tags                           = merge(lookup(var.tags, "resource-group", {}), lookup(var.tags, "all", {}))
}

//********************** Network Security Group **************************//
module "network_security_group" {
  source              = "../common/network-security-group"
  nsg_id              = var.nsg_id
  resource_group_name = module.common.resource_group_name
  security_group_name = "${module.common.resource_group_name}-nsg"
  location            = module.common.resource_group_location
  security_rules      = var.security_rules
  tags                = merge(lookup(var.tags, "network-security-group", {}), lookup(var.tags, "all", {}))
}

//********************** Networking **************************//
module "vnet" {
  depends_on = [
    module.network_security_group
  ]
  source                       = "../common/vnet"
  vnet_name                    = var.vnet_name
  resource_group_name          = module.common.resource_group_name
  existing_vnet_resource_group = var.existing_vnet_resource_group
  location                     = module.common.resource_group_location
  address_space                = var.address_space
  subnet_prefixes              = var.subnet_prefixes
  subnet_names                 = [var.frontend_subnet_name, var.backend_subnet_name]
  nsg_id                       = module.network_security_group.id
  tags                         = var.tags
}

resource "random_id" "public_ip_suffix" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = module.common.resource_group_name
  }
  byte_length = 8
}

resource "azurerm_public_ip" "public_ip" {
  name                    = var.single_gateway_name
  location                = module.common.resource_group_location
  resource_group_name     = module.common.resource_group_name
  allocation_method       = module.vnet.allocation_method
  sku                     = var.sku
  idle_timeout_in_minutes = 30
  domain_name_label       = "${lower(var.single_gateway_name)}-${random_id.public_ip_suffix.hex}"
  tags                    = merge(lookup(var.tags, "public-ip", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_network_interface_security_group_association" "security_group_association" {
  depends_on = [
    azurerm_network_interface.nic,
    module.network_security_group
  ]
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = module.network_security_group.id
}

resource "azurerm_network_interface" "nic" {
  depends_on = [
    azurerm_public_ip.public_ip,
    module.vnet
  ]
  name                          = "${var.single_gateway_name}-eth0"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true


  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.vnet.subnets[0]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 4)
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = merge(lookup(var.tags, "network-interface", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_network_interface" "nic1" {
  depends_on = [
    module.vnet
  ]
  name                          = "${var.single_gateway_name}-eth1"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true


  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = module.vnet.subnets[1]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[1], 4)
  }

  tags = merge(lookup(var.tags, "network-interface", {}), lookup(var.tags, "all", {}))
}

//********************** Storage accounts **************************//
module "vm_boot_diagnostics_storage" {
  source                                       = "../common/storage-account"
  storage_account_deployment_mode              = var.storage_account_deployment_mode
  existing_storage_account_name                = var.existing_storage_account_name
  existing_storage_account_resource_group_name = var.existing_storage_account_resource_group_name
  resource_group_name                          = module.common.resource_group_name
  location                                     = module.common.resource_group_location
  add_storage_account_ip_rules                 = var.add_storage_account_ip_rules
  storage_account_additional_ips               = var.storage_account_additional_ips
  tags                                         = merge(lookup(var.tags, "storage-account", {}), lookup(var.tags, "all", {}))
}

//********************** Virtual Machines **************************//
module "custom_image" {
  source               = "../common/custom-image"
  source_image_vhd_uri = var.source_image_vhd_uri
  resource_group_name  = module.common.resource_group_name
  location             = module.common.resource_group_location
  tags                 = merge(lookup(var.tags, "custom-image", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_virtual_machine" "single_gateway_vm_instance" {
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_interface.nic1
  ]
  location                      = module.common.resource_group_location
  zones                         = var.zone == "" ? null : [var.zone]
  name                          = var.single_gateway_name
  network_interface_ids         = [azurerm_network_interface.nic.id, azurerm_network_interface.nic1.id]
  resource_group_name           = module.common.resource_group_name
  vm_size                       = module.common.vm_size
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id  = azurerm_network_interface.nic.id

  identity {
    type = module.common.vm_instance_identity
  }

  dynamic "plan" {
    for_each = module.custom_image.create_custom_image ? [] : [1]
    content {
      name      = module.common.vm_os_sku
      publisher = module.common.publisher
      product   = module.common.vm_os_offer
    }
  }

  boot_diagnostics {
    enabled     = module.vm_boot_diagnostics_storage.boot_diagnostics
    storage_uri = module.vm_boot_diagnostics_storage.storage_account_primary_blob_endpoint
  }

  os_profile {
    computer_name  = lower(var.single_gateway_name)
    admin_username = module.common.admin_username
    admin_password = module.common.admin_password
    custom_data = templatefile("${path.module}/cloud-init.sh", {
      installation_type              = module.common.installation_type
      allow_upload_download          = module.common.allow_upload_download
      os_version                     = module.common.os_version
      module_name                    = module.common.module_name
      module_version                 = module.common.module_version
      template_type                  = "terraform"
      is_blink                       = module.common.is_blink
      bootstrap_script64             = base64encode(var.bootstrap_script)
      location                       = module.common.resource_group_location
      admin_shell                    = var.admin_shell
      sic_key                        = var.sic_key
      management_GUI_client_network  = var.management_GUI_client_network
      smart_1_cloud_token            = var.smart_1_cloud_token
      enable_custom_metrics          = var.enable_custom_metrics ? "yes" : "no"
      serial_console_password_hash   = var.serial_console_password_hash
      maintenance_mode_password_hash = var.maintenance_mode_password_hash
    })
  }

  os_profile_linux_config {
    disable_password_authentication = module.common.SSH_authentication_type_condition

    dynamic "ssh_keys" {
      for_each = module.common.SSH_authentication_type_condition ? [1] : []
      content {
        path     = "/home/notused/.ssh/authorized_keys"
        key_data = var.admin_SSH_key
      }
    }
  }

  storage_image_reference {
    id        = module.custom_image.id
    publisher = module.custom_image.create_custom_image ? null : module.common.publisher
    offer     = module.common.vm_os_offer
    sku       = module.common.vm_os_sku
    version   = module.common.vm_os_version
  }

  storage_os_disk {
    name              = var.single_gateway_name
    create_option     = module.common.storage_os_disk_create_option
    caching           = module.common.storage_os_disk_caching
    managed_disk_type = module.vm_boot_diagnostics_storage.storage_account_type
    disk_size_gb      = module.common.disk_size
  }

  tags = merge(lookup(var.tags, "virtual-machine", {}), lookup(var.tags, "all", {}))
}
