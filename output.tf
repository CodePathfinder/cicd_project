#########################################
# Output IP addresses
#########################################

output "PublicIP-a" {
  value = aws_instance.webserver-a.public_ip
}

output "PrivateIP-a" {
  value = aws_instance.webserver-a.private_ip
}

output "PublicIP-b" {
  value = aws_instance.webserver-b.public_ip
}

output "PrivateIP-b" {
  value = aws_instance.webserver-b.private_ip
}