locals {
  create_new_nsg = var.enable_nsg && var.nsg_id == ""
}
