#########################################
# Create 'webservers' in 'public-a'
#########################################

resource "aws_instance" "webserver" {
  count                  = var.COUNT
  ami                    = var.AMIS[var.OS]
  instance_type          = var.TYPE
  key_name               = var.PRIV_KEY
  subnet_id              = aws_subnet.public-a.id
  vpc_security_group_ids = [
    aws_security_group.allow-web.id, 
    aws_security_group.allow-ssh.id
  ]
  user_data = file(web.sh)
  tags = {
    Name    = "web-${format("%02d", count.index + 1)}"
    Group   = "webservers"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
    OS = var.OS
  }
}
  
##########################################
#  Save hosts.txt (IP-addresses) remotely 
##########################################

locals {
  group_name = aws_instance.webserver[0].tags.Group
  group_ips = join("\n", aws_instance.webserver[*].privat_ip)
  group_data = "[${local.group_name}]\n${local.group_ips}"
}

resource "aws_s3_bucket_object" "dev_hosts" {
  bucket = "terraform-state-cicd"
  key = "dev_hosts/hosts.txt"
  acl = "private"
  content = local.group_data
  depends_on = [aws_instance.webserver]
}
