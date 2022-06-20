#########################################
# ===== Output DNS and IP addresses =====
#########################################

output "elb_address" {
  value = aws_elb.web.dns_name
}

output "PrivateIPs" {
  value = aws_instance.webserver[*].private_ip
}

output "PublicIPs" {
  value = aws_instance.webserver[*].public_ip
}

