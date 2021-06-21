locals {
  cognito_vars = var.app_auth_domain != null && var.aws_cognito_user_pool_client != null ? [
    {
      name  = "GF_AUTH_GENERIC_OAUTH_ENABLED"
      value = "true"
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_NAME"
      value = "Cognito"
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP"
      value = var.aws_cognito_allow_signup
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_SCOPES"
      value = "openid,profile,email"
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_AUTH_URL"
      value = "https://${var.app_auth_domain}/oauth2/authorize"
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_TOKEN_URL"
      value = "https://${var.app_auth_domain}/oauth2/token"
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_API_URL"
      value = "https://${var.app_auth_domain}/oauth2/userInfo"
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_CLIENT_ID"
      value = var.aws_cognito_user_pool_client.id
    },
    {
      name  = "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET"
      value = var.aws_cognito_user_pool_client.client_secret
    }
  ] : []
}
