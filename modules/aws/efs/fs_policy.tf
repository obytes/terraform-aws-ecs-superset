resource "aws_efs_file_system_policy" "default" {
  file_system_id = aws_efs_file_system.default.id
  policy         = data.aws_iam_policy_document.efs.json
}

data "aws_iam_policy_document" "efs" {
  statement {

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]

    resources = [
      aws_efs_file_system.default.arn
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "true"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values = [
        aws_efs_access_point.default.arn
      ]
    }
  }
}
