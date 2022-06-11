#########################################
# Output IP addresses
#########################################

output "PublicIP" {
  value = aws_instance.webserver-a.public_ip
}

output "PrivateIP" {
  value = aws_instance.webserver-a.private_ip
}

output "PublicIP" {
  value = aws_instance.webserver-b.public_ip
}

output "PrivateIP" {
  value = aws_instance.webserver-b.private_ip
}