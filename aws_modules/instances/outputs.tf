##########################################
# ============== OUTPUTS =================
##########################################

output "private_ips" {
  value = aws_instance.webservers[*].private_ip
}

output "public_ips" {
  value = aws_instance.webservers[*].public_ip
}

output "hosts" {
  value = local.group_data
}
/*
output "load_balancer_url" {
  value = aws_elb.web.dns_name
}
*/
