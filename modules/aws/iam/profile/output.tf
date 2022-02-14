output "arn" {
  value = "${aws_iam_instance_profile.profile.arn}"
}

output "name" {
  value = "${aws_iam_instance_profile.profile.name}"
}
