variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "client_name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
}

variable "identity_pool_name" {
  description = "Name of the Cognito Identity Pool"
  type        = string
}

variable "allow_unauthenticated_identities" {
  description = "Whether to allow unauthenticated identities"
  type        = bool
  default     = false
}

variable "username_attributes" {
  description = "Attributes to be used as username in Cognito User Pool"
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified by Cognito"
  type        = list(string)
  default     = ["email"]
}

variable "password_policy" {
  description = "Password policy for the User Pool"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_numbers   = bool
    require_symbols   = bool
    require_uppercase = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

variable "temporary_password_validity_days" {
  description = "Number of days the temporary password is valid"
  type        = number
  default     = 7
}

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration"
  type        = string
  default     = "OFF"
}

variable "explicit_auth_flows" {
  description = "List of authentication flows to enable"
  type        = list(string)
  default     = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
}

variable "custom_attributes" {
  description = "Custom attributes to add to the User Pool"
  type = list(object({
    name                = string
    attribute_data_type = string
    mutable             = bool
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "authenticated_role_policy_arns" {
  description = "List of policy ARNs to attach to the authenticated role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}

variable "unauthenticated_role_policy_arns" {
  description = "List of policy ARNs to attach to the unauthenticated role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}
