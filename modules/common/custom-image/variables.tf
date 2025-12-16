//********************** Basic Configurations **************************//
variable "resource_group_name" {
  description = "Azure Resource Group name to build into."
  type        = string
}

variable "location" {
  description = "The location/region where the custom image will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions."
  type        = string
}

variable "tags" {
  description = "The tags to associate with the custom image."
  type        = map(string)
  default     = {}
}

//********************** Custom Image Variables **************************//
variable "source_image_vhd_uri" {
  description = "The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images."
  type        = string
  default     = "noCustomUri"
}
