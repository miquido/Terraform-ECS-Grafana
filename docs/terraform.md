<!-- markdownlint-disable -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb-ingress-grafana"></a> [alb-ingress-grafana](#module\_alb-ingress-grafana) | git::ssh://git@gitlab.com/miquido/terraform/terraform-alb-ingress.git | tags/3.1.8 |
| <a name="module_ecs-alb-task-grafana"></a> [ecs-alb-task-grafana](#module\_ecs-alb-task-grafana) | git::ssh://git@gitlab.com/miquido/terraform/terraform-ecs-alb-task.git | tags/5.5.4 |
| <a name="module_ecs-alb-task-grafana-envoy-proxy"></a> [ecs-alb-task-grafana-envoy-proxy](#module\_ecs-alb-task-grafana-envoy-proxy) | git::ssh://git@gitlab.com/miquido/terraform/terraform-ecs-envoy.git | tags/1.1.1 |
| <a name="module_grafana-appmesh"></a> [grafana-appmesh](#module\_grafana-appmesh) | git::ssh://git@gitlab.com/miquido/terraform/terraform-app-mesh-service.git | tags/1.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_route53_record.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.grafana_admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.grafana_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb"></a> [alb](#input\_alb) | Alb module from ssh://git@gitlab.com/miquido/terraform/terraform-alb.git | <pre>object({<br>    http_listener_arn  = string<br>    https_listener_arn = string<br>    alb_arn_suffix     = string<br>    alb_dns_name       = string<br>    alb_zone_id        = string<br>  })</pre> | `null` | no |
| <a name="input_app_auth_domain"></a> [app\_auth\_domain](#input\_app\_auth\_domain) | auth domain for aws cognito | `string` | `null` | no |
| <a name="input_aws_appmesh_mesh_id"></a> [aws\_appmesh\_mesh\_id](#input\_aws\_appmesh\_mesh\_id) | n/a | `string` | `null` | no |
| <a name="input_aws_cognito_allow_signup"></a> [aws\_cognito\_allow\_signup](#input\_aws\_cognito\_allow\_signup) | Should cognito users be able to signup into grafana | `bool` | `true` | no |
| <a name="input_aws_cognito_user_pool_client"></a> [aws\_cognito\_user\_pool\_client](#input\_aws\_cognito\_user\_pool\_client) | aws cognito user pool client | <pre>object({<br>    id            = string<br>    client_secret = string<br>  })</pre> | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Default AWS Region | `string` | n/a | yes |
| <a name="input_aws_service_discovery_private_dns_namespace"></a> [aws\_service\_discovery\_private\_dns\_namespace](#input\_aws\_service\_discovery\_private\_dns\_namespace) | n/a | <pre>object({<br>    name        = string<br>    id          = string<br>    hosted_zone = string<br>  })</pre> | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | domain under which grafana will be available. Required when alb is used | `string` | `null` | no |
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | resource aws\_ecs\_cluster where to deploy service | <pre>object({<br>    arn  = string<br>    name = string<br>  })</pre> | n/a | yes |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `any` | n/a | yes |
| <a name="input_ingress_priority"></a> [ingress\_priority](#input\_ingress\_priority) | The priority for the rules without authentication, between 1 and 50000 (1 being highest priority). Must be different from `authenticated_priority` since a listener can't have multiple rules with the same priority | `number` | `88` | no |
| <a name="input_mesh_route53_zone_id"></a> [mesh\_route53\_zone\_id](#input\_mesh\_route53\_zone\_id) | mesh route id to create grafana entry | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Account/Project Name | `string` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | route id to create grafana entry | `string` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name under which service will be deployed | `string` | `"grafana"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply on all created resources | `map(string)` | `{}` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | ECS task cpu for grafana | `number` | `256` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | ECS task memory for grafana | `number` | `512` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC module ssh://git@gitlab.com/miquido/terraform/terraform-vpc.git | <pre>object({<br>    vpc_main_security_group_id = string<br>    vpc_id                     = string<br>    private_subnet_ids         = list(string)<br>    vpc_main_security_group_id = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- markdownlint-restore -->