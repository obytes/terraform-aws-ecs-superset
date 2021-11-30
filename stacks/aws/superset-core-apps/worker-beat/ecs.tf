module "worker_beat_ecs" {
  source                                   = "../../../../modules/aws/ecs/"
  prefix                                   = var.prefix
  common_tags                              = var.common_tags
  kms_arn                                  = var.kms_arn
  vpc_id                                   = var.vpc_id
  ecs_service_subnet_ids                   = var.private_subnet_ids
  ecs_cluster                              = var.ecs_cluster
  desired_count                            = var.worker_beat_ecs_params["desired_count"]
  cpu                                      = var.worker_beat_ecs_params["cpu"]
  memory                                   = var.worker_beat_ecs_params["memory"]
  container_name                           = var.worker_beat_ecs_params["container_name"]
  container_port                           = var.worker_beat_ecs_params["port"]
  service_discovery                        = var.service_discovery
  ecs_service_security_group_ingress_rules = var.worker_beat_sg
  file_system_id                           = var.file_system_id
  efs_access_point_id                      = var.efs_access_point_id
  root_directory                           = "/"
  extra_iam = [
    {
      actions   = ["ssm:GetParameters", "secretsmanager:GetSecretValue"]
      resources = [data.aws_secretsmanager_secret.worker_secrets.arn]
    },
    {
      actions   = ["iam:PassRole"]
      resources = [var.ssm_role_arn]
    },
    {
      actions = [
        "ssm:AddTagsToResource",
        "ssm:CreateActivation",
        "ssm:DeregisterManagedInstance",
        "ssm:DescribeInstanceInformation"
      ],
      resources = [
        "*"
      ]
    },
    {
      actions = ["ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      resources = ["*"]
    }
  ]

  container_definitions = <<DEFINITION
[
  {
    "INSTANCE_NAME"  : "${var.worker_beat_ecs_params["container_name"]}",
    "image": "${var.ecr_repository_url}:${var.common_tags["env"]}",
    "name": "${var.worker_beat_ecs_params["container_name"]}",
    "readonlyRootFilesystem": false,
    "networkMode": "awsvpc",
    "command": [
      "/app/docker/docker-bootstrap.sh", "beat"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "/aws/ecs/${var.prefix}",
          "awslogs-region": "${var.common_tags["region"]}",
          "awslogs-stream-prefix": "${var.prefix}-"
      }
    },
    "mountPoints": [
          {
            "sourceVolume": "superset_app",
            "containerPath": "/app",
            "readOnly": false
          }
        ],
    "environment": [
      {
              "name": "COMPOSE_PROJECT_NAME",
              "value": "${var.env_vars["COMPOSE_PROJECT_NAME"]}"
            },
            {
              "name": "DATABASE_DB",
              "value": "${var.env_vars["DATABASE_DB"]}"
            },
            {
              "name": "DATABASE_USER",
              "value": "${var.env_vars["DATABASE_USER"]}"
            },
            {
              "name": "DATABASE_PORT",
              "value": "${var.env_vars["DATABASE_PORT"]}"
            },
            {
              "name": "REDIS_PORT",
              "value": "${var.env_vars["REDIS_PORT"]}"
            },
            {
              "name": "DATABASE_DIALECT",
              "value": "${var.env_vars["DATABASE_DIALECT"]}"
            },
            {
              "name": "FLASK_ENV",
              "value": "${var.env_vars["FLASK_ENV"]}"
            },
            {
              "name": "SUPERSET_ENV",
              "value": "${var.env_vars["SUPERSET_ENV"]}"
            },
            {
              "name": "SUPERSET_LOAD_EXAMPLES",
              "value": "${var.env_vars["SUPERSET_LOAD_EXAMPLES"]}"
            },
            {
              "name": "CYPRESS_CONFIG",
              "value": "${var.env_vars["CYPRESS_CONFIG"]}"
            },
            {
              "name": "SUPERSET_PORT",
              "value": "${var.env_vars["SUPERSET_PORT"]}"
            },
            {
              "name": "PYTHONPATH",
              "value": "${var.env_vars["PYTHONPATH"]}"
            },
            {
              "name": "REDIS_CELERY_DB ",
              "value": "${var.env_vars["REDIS_CELERY_DB"]}"
            },
            {
              "name": "REDIS_RESULTS_DB",
              "value": "${var.env_vars["REDIS_RESULTS_DB"]}"
            }
        ],
    "secrets": [
          {
            "name": "DATABASE_HOST",
            "valueFrom": "${data.aws_secretsmanager_secret.worker_secrets.arn}:DATABASE_HOST::"
          },
          {
            "name": "DATABASE_PASSWORD",
            "valueFrom": "${data.aws_secretsmanager_secret.worker_secrets.arn}:DATABASE_PASSWORD::"
          },
          {
            "name": "REDIS_HOST",
            "valueFrom": "${data.aws_secretsmanager_secret.worker_secrets.arn}:REDIS_HOST::"
          }
        ],
    "portMappings": [
      {
        "containerPort": ${var.worker_beat_ecs_params["port"]},
        "hostPort": ${var.worker_beat_ecs_params["port"]}
      }
    ]
  }
]
DEFINITION

}
