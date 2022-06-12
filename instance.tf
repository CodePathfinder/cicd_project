
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
# Create 'web-server' in 'public-a'
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
    Name    = var.OS
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
    Terraform   = "true"
  }
}

# ============ Tested code ==============

#########################################
# Create 'new-test-key' for webserver-b
#########################################

resource "aws_key_pair" "secret-key" {
  key_name   = "new-test-key"
  public_key = file("new-test-key.pub")
}

#########################################
# Create 'web-server' in 'public-b'
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
    Name    = var.OS
    Project = var.PROJECT
    Environment = "Stage"
    Terraform   = "true"
  }
# deploy script to remote webserver
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }
# run script on remote webserver
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/web.sh",
      "sed -i -e 's/\r$//' /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }
# connect to webserver-b with newly created key
  connection {
    user        = var.USER
    private_key = file(aws_key_pair.secret-key.new-test-key)
    host        = self.public_ip
  }
}
