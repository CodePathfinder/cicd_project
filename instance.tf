
#########################################
# Create 'allow-ssh' security group
#########################################

resource "aws_security_group" "allow-ssh" {
  vpc_id      = aws_vpc.main.id
  name        = "allow_ssh_sg"
  description = "Allow ssh inbound traffic from ${var.IP_ADDRESSES[var.SSH_CIDR]}"

  ingress {
    description = "SSH from ${var.IP_ADDRESSES[var.SSH_CIDR]}"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.IP_ADDRESSES[var.SSH_CIDR]]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh_sg"
  }
}

#########################################
# Create 'web-server' security group
#########################################

resource "aws_security_group" "allow-web" {
  vpc_id      = aws_vpc.main.id
  name        = "allow_web_sg"
  description = "Allow http inbound traffic from anywhere"

  ingress {
    description = "http from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_http_sg"
  }
}

#########################################
# Create 'webserver' in 'public-a'
#########################################

resource "aws_instance" "webserver-a" {
  ami                    = var.AMIS[var.OS]
  instance_type          = var.TYPE
  subnet_id              = aws_subnet.public-a.id
  key_name               = var.PRIV_KEY
  vpc_security_group_ids = [
    aws_security_group.allow-web.id, 
    aws_security_group.allow-ssh.id
  ]   
  tags = {
    Name    = "webserver-a"
    Project = var.PROJECT
    Environment = "Stage"
    Terraform   = "true"
    OS = "var.OS"
  }
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/web.sh",
      "sed -i -e 's/\r$//' /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${tags[Name]} ${self.private-ip} >> private_ips.txt"
  }
  connection {
    user        = var.USER
    private_key = file("/var/lib/jenkins/.ssh/${var.PRIV_KEY}")
    host        = self.public_ip
  }
}

# ============ Tested code ==============

#########################################
# Create 'webserver' in 'public-b'
#########################################

resource "aws_instance" "webserver-b" {
  ami                    = var.AMIS[var.OS]
  instance_type          = var.TYPE
  subnet_id              = aws_subnet.public-b.id
  key_name               = var.PRIV_KEY
  vpc_security_group_ids = [
    aws_security_group.allow-web.id, 
    aws_security_group.allow-ssh.id
  ]   
  tags = {
    Name    = "webserver-b"
    Project = var.PROJECT
    Environment = "Stage"
    Terraform   = "true"
    OS = "var.OS"
  }
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/web.sh",
      "sed -i -e 's/\r$//' /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }
  provisioner "local-exec" {
    command = "echo webserver-b: ${self.private_ip} >> private_ips.txt"
  }
  connection {
    user        = var.USER
    private_key = file("/var/lib/jenkins/.ssh/${var.PRIV_KEY}")
    host        = self.public_ip
  }
}
