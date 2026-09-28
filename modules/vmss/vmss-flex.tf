//********************** VMSS Flexible orchestration **************************//
resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss_flex" {
  count = local.is_flexible ? 1 : 0
  depends_on = [
    azurerm_lb_backend_address_pool.frontend_lb_pool_v6,
    azurerm_lb_backend_address_pool.backend_lb_pool_v6
  ]
  name                = var.vmss_name
  location            = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  sku_name            = module.common.vm_size
  instances           = local.number_of_vm_instances

  platform_fault_domain_count = var.platform_fault_domain_count

  zones = local.vmss_zones

  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }

  dynamic "source_image_reference" {
    for_each = module.custom_image.create_custom_image ? [] : [1]
    content {
      publisher = module.common.publisher
      offer     = module.common.vm_os_offer
      sku       = module.common.vm_os_sku
      version   = module.common.vm_os_version
    }
  }

  source_image_id = module.custom_image.id

  os_disk {
    caching              = module.common.storage_os_disk_caching
    storage_account_type = module.vm_boot_diagnostics_storage.storage_account_type
    disk_size_gb         = module.common.disk_size
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
    custom_data = local.vmss_custom_data

    linux_configuration {
      computer_name_prefix            = lower(var.vmss_name)
      admin_username                  = module.common.admin_username
      admin_password                  = module.common.SSH_authentication_type_condition ? null : module.common.admin_password
      disable_password_authentication = module.common.SSH_authentication_type_condition

      dynamic "admin_ssh_key" {
        for_each = module.common.SSH_authentication_type_condition ? [1] : []
        content {
          public_key = var.admin_SSH_key
          username   = module.common.admin_username
        }
      }
    }
  }

  boot_diagnostics {
    storage_account_uri = module.vm_boot_diagnostics_storage.storage_account_primary_blob_endpoint
  }

  network_api_version = "2020-11-01"

  network_interface {
    name                          = "eth0"
    primary                       = true
    enable_ip_forwarding          = true
    enable_accelerated_networking = true
    ip_configuration {
      name      = "ipconfig1"
      subnet_id = module.vnet.subnets[0]
      load_balancer_backend_address_pool_ids = local.create_frontend_lb ? [azurerm_lb_backend_address_pool.frontend_lb_pool[0].id] : (
        length(var.frontend_lb_pool_ids) > 0 ? var.frontend_lb_pool_ids : null
      )
      primary = true
      version = "IPv4"
      dynamic "public_ip_address" {
        for_each = var.instance_level_public_ipv4 ? [1] : []
        content {
          name                    = "${var.vmss_name}-public-ip"
          idle_timeout_in_minutes = 15
        }
      }
    }
    dynamic "ip_configuration" {
      for_each = var.enable_ipv6 ? [1] : []
      content {
        name      = "ipconfig1-v6"
        subnet_id = module.vnet.subnets[0]
        load_balancer_backend_address_pool_ids = local.create_frontend_lb ? [azurerm_lb_backend_address_pool.frontend_lb_pool_v6[0].id] : (
          length(var.frontend_lb_pool_v6_ids) > 0 ? var.frontend_lb_pool_v6_ids : null
        )
        primary = false
        version = "IPv6"
      }
    }
  }

  network_interface {
    name                          = "eth1"
    primary                       = false
    enable_ip_forwarding          = true
    enable_accelerated_networking = true
    ip_configuration {
      name      = "ipconfig2"
      subnet_id = module.vnet.subnets[1]
      load_balancer_backend_address_pool_ids = local.create_backend_lb ? [azurerm_lb_backend_address_pool.backend_lb_pool[0].id] : (
        length(var.backend_lb_pool_ids) > 0 ? var.backend_lb_pool_ids : null
      )
      primary = true
      version = "IPv4"
    }
    dynamic "ip_configuration" {
      for_each = var.enable_ipv6 ? [1] : []
      content {
        name      = "ipconfig2-v6"
        subnet_id = module.vnet.subnets[1]
        load_balancer_backend_address_pool_ids = local.create_backend_lb ? [azurerm_lb_backend_address_pool.backend_lb_pool_v6[0].id] : (
          length(var.backend_lb_pool_v6_ids) > 0 ? var.backend_lb_pool_v6_ids : null
        )
        primary = false
        version = "IPv6"
      }
    }
  }

  tags = merge(lookup(var.tags, "virtual-machine-scale-set", {}), lookup(var.tags, "all", {}), local.vmss_tags, { LegacyVMNVA = "" })
}
