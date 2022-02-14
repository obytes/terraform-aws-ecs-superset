resource "aws_iam_role" "role" {
  name               = "${var.name}"
  assume_role_policy = "${var.assume_role_policy}"
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name = "${var.name}"

  roles = [
    "${aws_iam_role.role.name}",
  ]

  policy_arn = "${var.policy_to_attach}"
}
