locals {
  module_name    = "high_availability_terraform_registry"
  module_version = "1.0.6"

  # Determine if Availability Set should be created
  availability_set_condition = var.availability_type == "Availability Set" ? true : false

  # Validate both s1c tokens are unqiue
  is_tokens_used = length(var.smart_1_cloud_token_a) > 0
  token_parts_a  = split(" ", var.smart_1_cloud_token_a)
  token_parts_b  = split(" ", var.smart_1_cloud_token_b)
  acutal_token_a = local.token_parts_a[length(local.token_parts_a) - 1]
  acutal_token_b = local.token_parts_b[length(local.token_parts_b) - 1]
  validate_tokens_uniqueness = local.is_tokens_used ? (
    local.acutal_token_a != local.acutal_token_b ? 0 : index("error", "Same Smart-1 Cloud token used for both memeber, you must provide unique token for each member")
  ) : 0
}
