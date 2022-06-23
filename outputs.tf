#########################################
# === Outputs | DNS and IP addresses ===
#########################################

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

# ======================================

output "elb_address" {
  value = aws_elb.web.dns_name
}

/*
output "PrivateIPs" {
  value = aws_instance.webserver[*].private_ip
}

output "PublicIPs" {
  value = aws_instance.webserver[*].public_ip
}
*/