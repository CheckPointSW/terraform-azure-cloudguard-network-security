locals {
  // Create a new VWAN only if vwan_hub_address_prefix is provided
  create_new_vwan = var.vwan_hub_address_prefix != "" ? true : false
}
