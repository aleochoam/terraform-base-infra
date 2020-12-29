output "cname" {
  value = aws_elastic_beanstalk_environment.env.cname
}

output "eb-ec2_role" {
  value = aws_iam_role.ec2_role.name
}
