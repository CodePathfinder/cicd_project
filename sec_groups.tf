
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
    cidr_blocks = [var.IP_ADDRESSES[var.SSH_CIDR], "172.31.0.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh_sg"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
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
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}
