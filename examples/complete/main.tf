provider "aws" {
  region = "us-east-1"
}

locals {
  top_domain             = "example.com"
  domain_prefix          = "stage"
  grafana_service_name   = "grafana"
  grafana_service_prefix = local.domain_prefix != "" ? "${local.grafana_service_name}.${local.domain_prefix}" : local.grafana_service_name
  grafana_service_domain = "${local.grafana_service_prefix}.${local.top_domain}"
}

module "grafana" {
  source     = "../../"
  aws_region = "eu-west-1" // var.aws_region
  ecs_cluster = {          // aws_ecs_cluster.main
    arn  = "arn::test::test"
    name = "main"
  }
  project = "example" // var.project
  vpc = {             // module.vpc
    vpc_main_security_group_id = "test_id"
    vpc_id                     = "test_id"
    private_subnet_ids         = ["test_id"]
    vpc_main_security_group_id = "test_id"
  }
  environment = "stage" // var.environment
  efs_id      = "test"  // aws_efs_file_system.efs.id

  /*********** Optional app mesh ************/
  aws_service_discovery_private_dns_namespace = { // aws_service_discovery_private_dns_namespace.map
    name        = "test"
    id          = "test"
    hosted_zone = "test"
  }
  app_mesh_id = "test"      // aws_appmesh_mesh.service.id
  app_mesh_route53_zone = { // aws_route53_zone.mesh_private_zone
    id   = "test"
    name = "test"
  }

  /*********** Optional alb ************/
  route53_zone_id = "test" //aws_route53_zone.default.zone_id
  alb = {                  // module.alb
    http_listener_arn  = "test"
    https_listener_arn = "test"
    alb_arn_suffix     = "test"
    alb_dns_name       = "test"
    alb_zone_id        = "test"
  }
  domain = local.grafana_service_domain

  /*********** Optional cognito auth ************/
  app_auth_domain = "auth.example.com"
  aws_cognito_user_pool_client = { // aws_cognito_user_pool_client.client
    id            = "test"
    client_secret = "test"
  }
  aws_cognito_allow_signup = true
}
