module "ecs_service_notifications" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.2"

  name        = "notifications"
  cluster_arn = module.ecs_cluster_notifications.arn

  cpu    = 1024
  memory = 4096

  container_definitions = {
    ("notifications") = {
      essential = true
      cpu       = 512
      memory    = 1024
      image     = module.ecr_notifications.repository_url

      port_mappings = [
        {
          name          = "notifications"
          containerPort = 5202
          hostPort      = 5202
          protocol      = "tcp"
        }
      ]

      readonly_root_filesystem  = false
      enable_cloudwatch_logging = false

      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/notifications"
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }

      memory_reservation = 100
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.ecs_alb_notifications.target_group_arns, 0)
      container_name   = "notifications"
      container_port   = 5202
    }
  }

  subnet_ids = module.vpc.private_subnets

  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      from_port                = 5202
      to_port                  = 5202
      protocol                 = "tcp"
      source_security_group_id = module.ecs_alb_sg_notifications.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_service_discovery_http_namespace" "notifications" {
  name = "notifications"
}

output "service_id_notifications" {
  description = "ARN that identifies the service"
  value       = module.ecs_service_notifications.id
}

output "service_name_notifications" {
  description = "Name of the service"
  value       = module.ecs_service_notifications.name
}

output "service_iam_role_name_notifications" {
  description = "Service IAM role name"
  value       = module.ecs_service_notifications.iam_role_name
}

output "service_iam_role_arn_notifications" {
  description = "Service IAM role ARN"
  value       = module.ecs_service_notifications.iam_role_arn
}

output "service_iam_role_unique_id_notifications" {
  description = "Stable and unique string identifying the service IAM role"
  value       = module.ecs_service_notifications.iam_role_unique_id
}

output "service_container_definitions_notifications" {
  description = "Container definitions"
  value       = module.ecs_service_notifications.container_definitions
}

output "service_task_definition_arn_notifications" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = module.ecs_service_notifications.task_definition_arn
}
