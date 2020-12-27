output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_cidr" {
  value = [aws_subnet.public.*.cidr_block]
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "servers_sg_id" {
  value = aws_security_group.servers.id
}

output "private_dbs_subnets_cidr" {
  value = [aws_subnet.private_dbs.*.cidr_block]
}

output "private_dbs_subnets" {
  value = aws_subnet.private_dbs.*.id
}

output "dbs_sg_id" {
  value = aws_security_group.dbs.id
}
