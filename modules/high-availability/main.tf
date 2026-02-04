//********************** Basic Configuration **************************//
module "common" {
  source                         = "../common/common"
  resource_group_name            = var.resource_group_name
  resource_group_create          = var.resource_group_create
  location                       = var.location
  is_zonal                       = var.availability_type == "Availability Zone"
  availability_zones_num         = tostring(length(var.availability_zones))
  availability_zones             = var.availability_zones
  admin_password                 = var.admin_password
  installation_type              = "cluster"
  module_name                    = local.module_name
  module_version                 = local.module_version
  number_of_vm_instances         = var.number_of_vm_instances
  allow_upload_download          = var.allow_upload_download
  vm_size                        = var.vm_size
  disk_size                      = var.disk_size
  is_blink                       = var.is_blink
  os_version                     = var.os_version
  vm_os_sku                      = var.vm_os_sku
  vm_os_offer                    = var.vm_os_offer
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
  security_group_name = "${module.common.resource_group_name}_nsg"
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


resource "random_id" "random_id" {
  byte_length = 13
  keepers = {
    rg_id = module.common.resource_group_id
  }
}

resource "azurerm_public_ip_prefix" "public_ip_prefix" {
  count               = var.use_public_ip_prefix && var.create_public_ip_prefix ? 1 : 0
  name                = "${module.common.resource_group_name}-ipprefix"
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  prefix_length       = length(var.vips_names) > 4 ? 28 : length(var.vips_names) > 0 ? 29 : 30
  tags                = merge(lookup(var.tags, "public-ip-prefix", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_public_ip" "public_ip" {
  count               = 2
  name                = "${var.cluster_name}${count.index + 1}_IP"
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method   = module.vnet.allocation_method
  sku                 = var.sku
  domain_name_label   = "${lower(var.cluster_name)}-${count.index + 1}-${random_id.random_id.hex}"
  public_ip_prefix_id = var.use_public_ip_prefix ? (var.create_public_ip_prefix ? azurerm_public_ip_prefix.public_ip_prefix[0].id : var.existing_public_ip_prefix_id) : null
  tags                = merge(lookup(var.tags, "public-ip", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_public_ip" "cluster_vip" {
  name                = var.cluster_name
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method   = module.vnet.allocation_method
  sku                 = var.sku
  domain_name_label   = "${lower(var.cluster_name)}-vip-${random_id.random_id.hex}"
  public_ip_prefix_id = var.use_public_ip_prefix ? (var.create_public_ip_prefix ? azurerm_public_ip_prefix.public_ip_prefix[0].id : var.existing_public_ip_prefix_id) : null
  tags                = merge(lookup(var.tags, "public-ip", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_public_ip" "vips" {
  count               = length(var.vips_names)
  name                = var.vips_names[count.index]
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method   = module.vnet.allocation_method
  sku                 = var.sku
  domain_name_label   = "${lower(var.vips_names[count.index])}-${count.index}-vip-${random_id.random_id.hex}"
  public_ip_prefix_id = var.use_public_ip_prefix ? (var.create_public_ip_prefix ? azurerm_public_ip_prefix.public_ip_prefix[0].id : var.existing_public_ip_prefix_id) : null
  tags                = merge(lookup(var.tags, "public-ip", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_network_interface" "nic_vip" {
  depends_on = [
    azurerm_public_ip.cluster_vip,
    azurerm_public_ip.public_ip,
    azurerm_public_ip.vips,
  ]
  name                          = "${var.cluster_name}1-eth0"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    subnet_id                     = module.vnet.subnets[0]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 5)
    public_ip_address_id          = azurerm_public_ip.public_ip.0.id
  }

  ip_configuration {
    name                          = "cluster-vip"
    subnet_id                     = module.vnet.subnets[0]
    primary                       = false
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 7)
    public_ip_address_id          = azurerm_public_ip.cluster_vip.id
  }

  dynamic "ip_configuration" {
    for_each = var.vips_names
    content {
      name                          = "cluster-vip-${index(var.vips_names, ip_configuration.value) + 1}"
      subnet_id                     = module.vnet.subnets[0]
      primary                       = false
      private_ip_address_allocation = module.vnet.allocation_method
      private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 7 + index(var.vips_names, ip_configuration.value) + 1)
      public_ip_address_id          = azurerm_public_ip.vips[index(var.vips_names, ip_configuration.value)].id
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to ip_configuration when Re-applying, e.g. because a cluster failover and associating the cluster- vip with the other member.
      # updates these based on some ruleset managed elsewhere.
      ip_configuration
    ]
  }

  tags = merge(lookup(var.tags, "network-interface", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_vip_lb_association" {
  depends_on = [
    azurerm_network_interface.nic_vip,
    azurerm_lb_backend_address_pool.frontend_lb_pool
  ]
  network_interface_id    = azurerm_network_interface.nic_vip.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend_lb_pool.id
}

resource "azurerm_network_interface" "nic" {
  depends_on = [
    azurerm_public_ip.public_ip,
    azurerm_lb.frontend_lb
  ]
  name                          = "${var.cluster_name}2-eth0"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    subnet_id                     = module.vnet.subnets[0]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 6)
    public_ip_address_id          = azurerm_public_ip.public_ip.1.id
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to ip_configuration when Re-applying, e.g. because a cluster failover and associating the cluster- vip with the other member.
      # updates these based on some ruleset managed elsewhere.
      ip_configuration
    ]
  }

  tags = merge(lookup(var.tags, "network-interface", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_lb_backend_address_pool.frontend_lb_pool
  ]
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend_lb_pool.id
}

resource "azurerm_network_interface" "nic1" {
  depends_on = [
    azurerm_lb.backend_lb
  ]
  count                         = 2
  name                          = "${var.cluster_name}${count.index + 1}-eth1"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = module.vnet.subnets[1]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[1], count.index + 5)
  }

  tags = merge(lookup(var.tags, "network-interface", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_network_interface_backend_address_pool_association" "nic1_lb_association" {
  depends_on = [
    azurerm_network_interface.nic1,
    azurerm_lb_backend_address_pool.backend_lb_pool
  ]
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic1[count.index].id
  ip_configuration_name   = "ipconfig2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_lb_pool.id
}

//********************** Load Balancers **************************//
resource "azurerm_public_ip" "public_ip_lb" {
  name                = "frontend_lb_ip"
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method   = module.vnet.allocation_method
  sku                 = var.sku
  domain_name_label   = "${lower(var.cluster_name)}-${random_id.random_id.hex}"
  public_ip_prefix_id = var.use_public_ip_prefix ? (var.create_public_ip_prefix ? azurerm_public_ip_prefix.public_ip_prefix[0].id : var.existing_public_ip_prefix_id) : null
  tags                = merge(lookup(var.tags, "public-ip", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_lb" "frontend_lb" {
  name                = "frontend-lb"
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  sku                 = var.sku

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontend"
    public_ip_address_id = azurerm_public_ip.public_ip_lb.id
  }

  tags = merge(lookup(var.tags, "load-balancer", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_lb_backend_address_pool" "frontend_lb_pool" {
  loadbalancer_id = azurerm_lb.frontend_lb.id
  name            = "frontend-lb-pool"
}

resource "azurerm_lb" "backend_lb" {
  name                = "backend-lb"
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  sku                 = var.sku

  frontend_ip_configuration {
    name                          = "backend-lb"
    subnet_id                     = module.vnet.subnets[1]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[1], 4)
  }

  tags = merge(lookup(var.tags, "load-balancer", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_lb_backend_address_pool" "backend_lb_pool" {
  name            = "backend-lb-pool"
  loadbalancer_id = azurerm_lb.backend_lb.id
}

resource "azurerm_lb_probe" "azure_lb_healprob" {
  count               = 2
  loadbalancer_id     = count.index == 0 ? azurerm_lb.frontend_lb.id : azurerm_lb.backend_lb.id
  name                = var.lb_probe_name
  protocol            = var.lb_probe_protocol
  port                = var.lb_probe_port
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
}

resource "azurerm_lb_rule" "backend_lb_rules" {
  loadbalancer_id                = azurerm_lb.backend_lb.id
  name                           = "backend-lb"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "backend-lb"
  load_distribution              = "Default"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_lb_pool.id]
  probe_id                       = azurerm_lb_probe.azure_lb_healprob[1].id
  enable_floating_ip             = var.enable_floating_ip
}

//********************** Availability Set **************************//
resource "azurerm_availability_set" "availability_set" {
  count                        = local.availability_set_condition ? 1 : 0
  name                         = "${var.cluster_name}-AvailabilitySet"
  location                     = module.common.resource_group_location
  resource_group_name          = module.common.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = merge(lookup(var.tags, "availability-set", {}), lookup(var.tags, "all", {}))
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

resource "azurerm_virtual_machine" "vm_instance_availability_set" {
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic_vip
  ]
  count                         = local.availability_set_condition ? module.common.number_of_vm_instances : 0
  name                          = "${var.cluster_name}${count.index + 1}"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  availability_set_id           = local.availability_set_condition ? azurerm_availability_set.availability_set[0].id : ""
  vm_size                       = module.common.vm_size
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id  = count.index == 0 ? azurerm_network_interface.nic_vip.id : azurerm_network_interface.nic.id
  network_interface_ids = count.index == 0 ? [
    azurerm_network_interface.nic_vip.id,
    azurerm_network_interface.nic1.0.id
    ] : [
    azurerm_network_interface.nic.id,
    azurerm_network_interface.nic1.1.id
  ]

  identity {
    type = module.common.vm_instance_identity
  }

  storage_image_reference {
    id        = module.custom_image.id
    publisher = module.custom_image.create_custom_image ? null : module.common.publisher
    offer     = module.common.vm_os_offer
    sku       = module.common.vm_os_sku
    version   = module.common.vm_os_version
  }

  storage_os_disk {
    name              = "${var.cluster_name}-${count.index + 1}"
    create_option     = module.common.storage_os_disk_create_option
    caching           = module.common.storage_os_disk_caching
    managed_disk_type = module.vm_boot_diagnostics_storage.storage_account_type
    disk_size_gb      = module.common.disk_size
  }

  dynamic "plan" {
    for_each = module.custom_image.create_custom_image ? [] : [1]
    content {
      name      = module.common.vm_os_sku
      publisher = module.common.publisher
      product   = module.common.vm_os_offer
    }
  }

  os_profile {
    computer_name  = "${lower(var.cluster_name)}${count.index + 1}"
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
      sic_key                        = var.sic_key
      tenant_id                      = var.tenant_id
      virtual_network                = module.vnet.name
      cluster_name                   = var.cluster_name
      external_private_addresses     = azurerm_network_interface.nic_vip.ip_configuration[1].private_ip_address
      enable_custom_metrics          = var.enable_custom_metrics ? "yes" : "no"
      admin_shell                    = var.admin_shell
      smart_1_cloud_token            = count.index == 0 ? var.smart_1_cloud_token_a : var.smart_1_cloud_token_b
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

  boot_diagnostics {
    enabled     = module.vm_boot_diagnostics_storage.boot_diagnostics
    storage_uri = module.vm_boot_diagnostics_storage.storage_account_primary_blob_endpoint
  }

  tags = merge(lookup(var.tags, "virtual-machine", {}), lookup(var.tags, "all", {}))
}

resource "azurerm_virtual_machine" "vm_instance_availability_zone" {
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic_vip
  ]
  count                         = local.availability_set_condition ? 0 : module.common.number_of_vm_instances
  name                          = "${var.cluster_name}${count.index + 1}"
  location                      = module.common.resource_group_location
  resource_group_name           = module.common.resource_group_name
  zones                         = length(var.availability_zones) == 0 ? [count.index + 1] : length(var.availability_zones) == 1 ? [var.availability_zones[0]] : [var.availability_zones[count.index]]
  vm_size                       = module.common.vm_size
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id  = count.index == 0 ? azurerm_network_interface.nic_vip.id : azurerm_network_interface.nic.id
  network_interface_ids = count.index == 0 ? [
    azurerm_network_interface.nic_vip.id,
    azurerm_network_interface.nic1.0.id
    ] : [
    azurerm_network_interface.nic.id,
    azurerm_network_interface.nic1.1.id
  ]

  identity {
    type = module.common.vm_instance_identity
  }

  storage_image_reference {
    id        = module.custom_image.id
    publisher = module.custom_image.create_custom_image ? null : module.common.publisher
    offer     = module.common.vm_os_offer
    sku       = module.common.vm_os_sku
    version   = module.common.vm_os_version
  }

  storage_os_disk {
    name              = "${var.cluster_name}-${count.index + 1}"
    create_option     = module.common.storage_os_disk_create_option
    caching           = module.common.storage_os_disk_caching
    managed_disk_type = module.vm_boot_diagnostics_storage.storage_account_type
    disk_size_gb      = module.common.disk_size
  }

  dynamic "plan" {
    for_each = module.custom_image.create_custom_image ? [] : [1]
    content {
      name      = module.common.vm_os_sku
      publisher = module.common.publisher
      product   = module.common.vm_os_offer
    }
  }

  os_profile {
    computer_name  = "${lower(var.cluster_name)}${count.index + 1}"
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
      sic_key                        = var.sic_key
      tenant_id                      = var.tenant_id
      virtual_network                = module.vnet.name
      cluster_name                   = var.cluster_name
      external_private_addresses     = cidrhost(module.vnet.subnet_prefixes[0], 7)
      enable_custom_metrics          = var.enable_custom_metrics ? "yes" : "no"
      admin_shell                    = var.admin_shell
      smart_1_cloud_token            = count.index == 0 ? var.smart_1_cloud_token_a : var.smart_1_cloud_token_b
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

  boot_diagnostics {
    enabled     = module.vm_boot_diagnostics_storage.boot_diagnostics
    storage_uri = module.vm_boot_diagnostics_storage.storage_account_primary_blob_endpoint
  }

  tags = merge(lookup(var.tags, "virtual-machine", {}), lookup(var.tags, "all", {}))
}

//********************** Role Assigments **************************//
data "azurerm_role_definition" "virtual_machine_contributor_role_definition" {
  name = "Virtual Machine Contributor"
}

data "azurerm_role_definition" "reader_role_definition" {
  name = "Reader"
}

resource "azurerm_role_assignment" "cluster_virtual_machine_contributor_assignment" {
  count              = 2
  scope              = module.common.resource_group_id
  role_definition_id = data.azurerm_role_definition.virtual_machine_contributor_role_definition.id
  principal_id       = local.availability_set_condition ? lookup(azurerm_virtual_machine.vm_instance_availability_set[count.index].identity[0], "principal_id") : lookup(azurerm_virtual_machine.vm_instance_availability_zone[count.index].identity[0], "principal_id")

  lifecycle {
    ignore_changes = [
      role_definition_id, principal_id
    ]
  }
}

resource "azurerm_role_assignment" "cluster_reader_assigment" {
  count              = 2
  scope              = module.common.resource_group_id
  role_definition_id = data.azurerm_role_definition.reader_role_definition.id
  principal_id       = local.availability_set_condition ? lookup(azurerm_virtual_machine.vm_instance_availability_set[count.index].identity[0], "principal_id") : lookup(azurerm_virtual_machine.vm_instance_availability_zone[count.index].identity[0], "principal_id")

  lifecycle {
    ignore_changes = [
      role_definition_id, principal_id
    ]
  }
}
