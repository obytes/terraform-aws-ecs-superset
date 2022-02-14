resource "aws_iam_policy" "policy" {
  name   = "${var.name}"
  path   = "${var.path}"
  policy = "${var.policy}"
}
