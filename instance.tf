
#########################################
# Create 'allow-ssh' security group
#########################################

resource "aws_security_group" "allow-ssh" {
  vpc_id      = aws_vpc.main.id
  name        = "allow_ssh_sg"
  description = "Allow ssh inbound traffic from MYIP"

  ingress {
    description = "SSH from MYIP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP, var.JenkinsSG]
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
    cidr_blocks = [aws_vpc.main.cidr_block]
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
# Create 'web-server' in 'public-a'
#########################################

resource "aws_instance" "webserver" {
  ami                    = var.AMIS[var.OS]
  instance_type          = var.TYPE
  subnet_id              = aws_subnet.public-a.id
  key_name               = var.PRIV_KEY
  vpc_security_group_ids = [
    aws_security_group.allow-web.id, 
    aws_security_group.allow-ssh.id
  ]   
  tags = {
    Name    = var.OS
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}

#########################################
# Output IP addresses
#########################################

output "PublicIP" {
  value = aws_instance.webserver.public_ip
}

output "PrivateIP" {
  value = aws_instance.webserver.private_ip
}
