output "vpc_id" {
  value = aws_vpc.bhargav.id
}

output "public_subnets" {
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnets" {
  value = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "nat_gateway_ids" {
  value = [aws_nat_gateway.nat_1.id, aws_nat_gateway.nat_2.id]
}

output "eip_ids" {
  value = [aws_eip.eip_1.id, aws_eip.eip_2.id]
}