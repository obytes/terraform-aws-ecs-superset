resource "aws_iam_policy" "ecs-policy" {
  name   = "${local.prefix}-ecs-pl"
  path   = "/"
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = [
      var.kms_arn,
    ]
  }

  dynamic "statement" {
    for_each = var.extra_iam
    content {
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

resource "aws_iam_role" "ecs-role" {
  name               = "${local.prefix}-ecs-rl"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  description        = "${local.prefix} ECS Execution role"
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-attach_policy" {
  policy_arn = aws_iam_policy.ecs-policy.arn
  role       = aws_iam_role.ecs-role.name
}

resource "aws_iam_role_policy_attachment" "_" {
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
  role       = aws_iam_role.ecs-role.name
}
