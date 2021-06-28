variable "alb" {
  type = object({
    http_listener_arn  = string
    https_listener_arn = string
    alb_arn_suffix     = string
    alb_dns_name       = string
    alb_zone_id        = string
  })
  default     = null
  description = "Alb module from ssh://git@gitlab.com/miquido/terraform/terraform-alb.git"
}

variable "ecs_cluster" {
  type = object({
    arn  = string
    name = string
  })
  description = "resource aws_ecs_cluster where to deploy service"
}

variable "service_name" {
  type        = string
  default     = "grafana"
  description = "Name under which service will be deployed"
}

variable "vpc" {
  type = object({
    vpc_main_security_group_id = string
    vpc_id                     = string
    private_subnet_ids         = list(string)
    vpc_main_security_group_id = string
  })
  description = "VPC module ssh://git@gitlab.com/miquido/terraform/terraform-vpc.git"
}

variable "domain" {
  type        = string
  description = "domain under which grafana will be available. Required when alb is used"
  default     = null
}

variable "ingress_priority" {
  type        = number
  default     = 88
  description = "The priority for the rules without authentication, between 1 and 50000 (1 being highest priority). Must be different from `authenticated_priority` since a listener can't have multiple rules with the same priority"
}

variable "app_mesh_aws_service_discovery_private_dns_namespace" {
  type = object({
    name        = string
    id          = string
    hosted_zone = string
  })
  default     = null
  description = "app mesh private DNS namespace"
}

variable "app_mesh_route53_zone" {
  type = object({
    id   = string
    name = string
  })
  default     = null
  description = "app_mesh route zone to create service entry"
}

variable "route53_zone_id" {
  type        = string
  default     = null
  description = "route id to create grafana entry"
}

variable "app_mesh_id" {
  type        = string
  default     = null
  description = "app mesh id to create service entry"
}

variable "project" {
  type        = string
  description = "Account/Project Name"
}

variable "environment" {
  description = "Environment name"
}

variable "aws_region" {
  type        = string
  description = "Default AWS Region"
}

variable "aws_service_discovery_private_dns_namespace" {
  type = object({
    name        = string
    id          = string
    hosted_zone = string
  })
  default = null
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply on all created resources"
  default     = {}
}

variable "task_cpu" {
  type        = number
  default     = 256
  description = "ECS task cpu for grafana"
}

variable "task_memory" {
  type        = number
  default     = 512
  description = "ECS task memory for grafana"
}

variable "efs_id" {
  type = string
}

variable "app_auth_domain" {
  type        = string
  default     = null
  description = "auth domain for aws cognito"
}

variable "aws_cognito_user_pool_client" {
  type = object({
    id            = string
    client_secret = string
  })
  default     = null
  description = "aws cognito user pool client"
}

variable "aws_cognito_allow_signup" {
  type        = bool
  default     = true
  description = "Should cognito users be able to signup into grafana"
}

variable "enable_app_mesh" {
  type        = bool
  default     = true
  description = "Should appmesh resources be created. Required vars: aws_service_discovery_private_dns_namespace, aws_appmesh_mesh_id, mesh_route53_zone_id"
}
