locals {
  // Create a new NSG only if nsg_id is not provided
  create_new_nsg = var.nsg_id == "" ? true : false
}
