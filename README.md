# tf-module-cognito

```hcl
module "cognito" {
  source               = "git::https://github.com/michaeltuszynski/tf-module-cognito.git?ref=main"
  user_pool_name    = "my-app-user-pool"
  client_name       = "my-app-client"
  identity_pool_name = "my-app-identity-pool"

  username_attributes      = ["email", "username"]
  auto_verified_attributes = ["email"]

  custom_attributes = [
    {
      name                = "email"
      attribute_data_type = "String"
      mutable             = true
      min_length          = 3
      max_length          = 256
    },
    {
      name                = "username"
      attribute_data_type = "String"
      mutable             = false
      min_length          = 3
      max_length          = 256
    },
    {
      name                = "custom_attr"
      attribute_data_type = "String"
      mutable             = true
      min_length          = 1
      max_length          = 256
    }
  ]

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}

# You can then use the outputs like this:
output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}
```

test change
