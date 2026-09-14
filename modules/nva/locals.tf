locals {
  license_types = {
    "Security Enforcement (NGTP)"                           = ""
    "Full Package (NGTX and Smart-1 Cloud)"                 = "-ngtx"
    "Full Package Premium (NGTX and Smart-1 Cloud Premium)" = "-premium"
  }

  extranic_scale_unit_min = var.nics_number == 3 ? 10 : 2
}
