resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase                = var.password_policy.require_lowercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    require_uppercase                = var.password_policy.require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  mfa_configuration = var.mfa_configuration

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Account Confirmation"
    email_message        = "Your confirmation code is {####}"
  }

  dynamic "schema" {
    for_each = var.custom_attributes
    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      mutable             = schema.value.mutable
    }
  }

  lifecycle {
    ignore_changes = [
      "schema"
    ]
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "client" {
  name = var.client_name

  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret     = false
  explicit_auth_flows = var.explicit_auth_flows
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  tags = var.tags
}

resource "aws_iam_role" "authenticated" {
  name = "${var.user_pool_name}-authenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "authenticated_policy" {
  count      = length(var.authenticated_role_policy_arns)
  policy_arn = var.authenticated_role_policy_arns[count.index]
  role       = aws_iam_role.authenticated.name
}

resource "aws_iam_role" "unauthenticated" {
  name = "${var.user_pool_name}-unauthenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "unauthenticated_policy" {
  count      = length(var.unauthenticated_role_policy_arns)
  policy_arn = var.unauthenticated_role_policy_arns[count.index]
  role       = aws_iam_role.unauthenticated.name
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    authenticated   = aws_iam_role.authenticated.arn
    unauthenticated = aws_iam_role.unauthenticated.arn
  }
}

