output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.main.id
}

output "default_rt_id" {
  value = aws_vpc.main.default_route_table_id
}