locals {
  custom_image_condition = var.source_image_vhd_uri == "noCustomUri" ? false : true
}
