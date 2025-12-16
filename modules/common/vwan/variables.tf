//********************** Basic Configurations **************************//
variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "tags" {
  description = "Assign tags by resource."
  type        = map(map(string))
  default     = {}
}

//********************** Virtual WAN Configurations **************************//
variable "vwan_name" {
  description = "The name of the Virtual WAN."
  type        = string
}

variable "vwan_hub_name" {
  description = "The name of the Virtual Hub."
  type        = string
}

variable "vwan_hub_resource_group" {
  description = "The resource group name for the Virtual Hub when using an existing VWAN."
  type        = string
}

variable "vwan_hub_address_prefix" {
  description = "The address prefix for the Virtual Hub."
  type        = string
}
