locals {
  grafana_service_port              = 3000
  grafana_service_health_check_path = "/api/health"
  grafana_service_image_repository  = "miquidocompany/grafana"
  grafana_service_image_tag         = "7.5.7"
  appmesh_grafana_service_dns       = "${var.service_name}.${local.appmesh_domain}"
  appmesh_grafana_cloud_map_dns     = var.aws_service_discovery_private_dns_namespace != null ? replace(local.appmesh_grafana_service_dns, local.appmesh_domain, var.aws_service_discovery_private_dns_namespace.name) : null
  appmesh_domain                    = "${var.environment}.app.mesh.local"

  alb_target_group_arn = join("", module.alb-ingress-grafana.*.target_group_arn)
  app_mesh_count       = var.aws_service_discovery_private_dns_namespace != null && var.aws_appmesh_mesh_id != null && var.mesh_route53_zone_id != null ? 1 : 0


}

module "alb-ingress-grafana" {
  source      = "git::ssh://git@gitlab.com/miquido/terraform/terraform-alb-ingress.git?ref=tags/3.1.8"
  name        = var.service_name
  project     = var.project
  environment = var.environment
  tags        = var.tags
  vpc_id      = var.vpc.vpc_id
  listener_arns = [
  var.alb.http_listener_arn, var.alb.https_listener_arn]
  hosts                                      = [var.domain]
  port                                       = local.grafana_service_port
  health_check_path                          = local.grafana_service_health_check_path
  health_check_healthy_threshold             = 2
  health_check_interval                      = 20
  health_check_unhealthy_threshold           = 2
  alb_target_group_alarms_enabled            = true
  alb_target_group_alarms_treat_missing_data = "notBreaching"
  alb_arn_suffix                             = var.alb.alb_arn_suffix
  priority                                   = var.ingress_priority
}

resource "aws_route53_record" "grafana" {
  count   = var.alb != null && var.domain != null ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.alb.alb_dns_name
    zone_id                = var.alb.alb_zone_id
    evaluate_target_health = true
  }
}
module "ecs-alb-task-grafana-envoy-proxy" {
  count                             = local.app_mesh_count
  source                            = "git::ssh://git@gitlab.com/miquido/terraform/terraform-ecs-envoy.git?ref=tags/1.1.1"
  appmesh-resource-arn              = module.grafana-appmesh[count.index].appmesh-resource-arn
  awslogs-group                     = module.ecs-alb-task-grafana.log_group_name
  awslogs-region                    = var.aws_region
  app-ports                         = local.grafana_service_port
  container_name                    = "${var.project}-${var.environment}-${var.service_name}"
  aws_service_discovery_service_arn = module.grafana-appmesh[count.index].aws_service_discovery_service_arn
  egress-ignored-ports              = ""

}

module "ecs-alb-task-grafana" {
  source = "git::ssh://git@gitlab.com/miquido/terraform/terraform-ecs-alb-task.git?ref=tags/5.6.1"

  name                              = var.service_name
  project                           = var.project
  environment                       = var.environment
  tags                              = var.tags
  container_image                   = local.grafana_service_image_repository
  container_tag                     = local.grafana_service_image_tag
  container_port                    = local.grafana_service_port
  health_check_grace_period_seconds = 10
  task_cpu                          = 512
  task_memory                       = 1024
  desired_count                     = 1
  autoscaling_min_capacity          = 1
  autoscaling_max_capacity          = 1
  autoscaling_enabled               = false
  ecs_alarms_enabled                = true
  assign_public_ip                  = false
  readonly_root_filesystem          = false
  logs_region                       = var.aws_region
  vpc_id                            = var.vpc.vpc_id
  alb_target_group_arn              = module.alb-ingress-grafana.target_group_arn
  ecs_cluster_arn                   = var.ecs_cluster.arn
  security_group_ids = [
    var.vpc.vpc_main_security_group_id
  ]
  subnet_ids            = var.vpc.private_subnet_ids
  ecs_cluster_name      = var.ecs_cluster.name
  platform_version      = "1.4.0"
  additional_containers = [join("", module.ecs-alb-task-grafana-envoy-proxy.*.json_map_encoded)]
  exec_enabled          = true

  force_new_deployment           = true
  ignore_changes_task_definition = false

  volumes = [
    {
      name                        = "data"
      host_path                   = null
      docker_volume_configuration = []
      efs_volume_configuration = [
        {
          file_system_id          = var.efs_id
          root_directory          = "/"
          transit_encryption      = "ENABLED"
          transit_encryption_port = 2999
          authorization_config = [{
            access_point_id = aws_efs_access_point.grafana.id
            iam             = "ENABLED"
          }]
      }]
    }
  ]

  mount_points = [
    {
      containerPath = "/var/lib/grafana"
      sourceVolume  = "data"
      readOnly      = false
    }
  ]

  healthcheck = {
    command = [
      "CMD-SHELL",
    "curl -s http://localhost:${local.grafana_service_port}${local.grafana_service_health_check_path}"]
    interval    = 20
    retries     = 2
    startPeriod = 100
    timeout     = 2
  }

  service_registries   = length(module.ecs-alb-task-grafana-envoy-proxy) == 1 ? module.ecs-alb-task-grafana-envoy-proxy[0].service_registries : []
  container_depends_on = length(module.ecs-alb-task-grafana-envoy-proxy) == 1 ? [module.ecs-alb-task-grafana-envoy-proxy[0].container_dependant] : null
  proxy_configuration  = length(module.ecs-alb-task-grafana-envoy-proxy) == 1 ? module.ecs-alb-task-grafana-envoy-proxy[0].proxy_configuration : null

  capacity_provider_strategies = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = null
    }
  ]

  secrets = [
    {
      name      = "GF_SECURITY_ADMIN_PASSWORD"
      valueFrom = aws_ssm_parameter.grafana_admin_password.arn
    }
  ]

  envs = concat(local.cognito_vars,
    [{
      name  = "GF_SERVER_ROOT_URL"
      value = "https://${var.domain}/"
      },
      {
        name  = "GF_SERVER_PROTOCOL"
        value = "http"
  }])
}

resource "aws_efs_access_point" "grafana" {
  file_system_id = var.efs_id
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    path = "/grafana"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
  }
}

resource "random_password" "grafana_admin" {
  length  = 32
  lower   = true
  number  = true
  upper   = true
  special = false
}

// uncomment after grafana is ready
//provider "grafana" {
//  url  = "https://grafana.showcase.miquido.cloud"
//  auth = "admin:${random_password.grafana_admin.result}"
//}
//


//resource "grafana_data_source" "grafana" {
//  type          = "grafana"
//  name          = "myapp-metrics"
//  url           = "${local.appmesh_grafana_service_dns}:${local.grafana_service_port}"
//}
//
//resource "grafana_dashboard" "sample" {
//  config_json = file("${path.module}/grafana_sample_dash.json")
//}

resource "aws_ssm_parameter" "grafana_admin_password" {
  name  = "/${var.environment}/grafana/admin_password"
  type  = "SecureString"
  value = random_password.grafana_admin.result
}

module "grafana-appmesh" {
  count                    = local.app_mesh_count
  source                   = "git::ssh://git@gitlab.com/miquido/terraform/terraform-app-mesh-service.git?ref=tags/1.0.1"
  app_health_check_path    = local.grafana_service_health_check_path
  app_port                 = local.grafana_service_port
  appmesh_domain           = local.appmesh_domain
  appmesh_name             = var.aws_appmesh_mesh_id
  appmesh_service_name     = var.service_name
  cloud_map_dns            = local.appmesh_grafana_cloud_map_dns
  cloud_map_hosted_zone_id = var.aws_service_discovery_private_dns_namespace.hosted_zone
  cloud_map_namespace_name = var.aws_service_discovery_private_dns_namespace.name
  map_id                   = var.aws_service_discovery_private_dns_namespace.id
  tags                     = var.tags
  task_role_name           = module.ecs-alb-task-grafana.task_role_name
  zone_id                  = var.mesh_route53_zone_id
}
