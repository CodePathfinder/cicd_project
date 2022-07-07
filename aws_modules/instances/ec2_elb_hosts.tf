# ===========================================================
# Provision Web in My VPC + save hosts.txt
# Create:
#   - Security Groups for Web Server
#   - Instances in Public Subnets (1 per subnet)
#   - Classic Load Balancer for Public Subnets/Instances
#   - Collect Private IPs -> hosts/${var.env}_hosts.txt in S3 bucket
# Outputs:
#   - Private_IPs
#   - Public_IPs
#   - Hosts
#   - Load Balancer URL
# ===========================================================

#########################################
# ============== AMI LOOKUP =============
#########################################

# ============ Ubuntu 20.04 =============
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# =========== Amazon Linux 2 ============
data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-*-hvm-*-x86_64-gp2"]
  }
}

#########################################
# =========== SECURITY GROUPS ===========
#########################################

# ========= 'ssh' security group ========

resource "aws_security_group" "ssh" {
  vpc_id      = var.vpcid
  name        = "ssh_sg"
  description = "Allow ssh inbound traffic from Jenkins and MyIP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/24", "176.100.9.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "${var.env}-ssh-sg"
    Project = var.project
  }
}

# ========= 'web' security group ========

resource "aws_security_group" "web" {
  vpc_id      = var.vpcid
  name        = "web_sg"
  description = "Allow http inbound traffic from anywhere"

  ingress {
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
    Name    = "${var.env}-http-sg"
    Project = var.project
  }
}

#########################################
#  Create Web Servers in public_subnets
#########################################

resource "aws_instance" "webservers" {
  count         = length(var.public_ids)
  ami           = var.user == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.amazon_linux.id
  instance_type = var.type
  key_name      = var.key_name
  subnet_id     = element(var.public_ids, count.index)
  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.ssh.id
  ]
  #  user_data                   = file("user_data.sh")
  #  user_data_replace_on_change = true
  tags = {
    Name    = "${var.env}-web-${format("%02d", count.index + 1)}"
    Group   = "webservers"
    Project = var.project
  }
}

###############################################
# ========== Classic Load Balancer ============
###############################################

resource "aws_elb" "web" {
  name            = "${var.env}-web-elb"
  security_groups = [aws_security_group.web.id]
  subnets         = var.public_ids

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  instances                 = aws_instance.webservers[*].id
  cross_zone_load_balancing = true

  tags = {
    Name    = "${var.env}-web-elb"
    Project = var.project
  }
}

##########################################
#  Save hosts.txt (IP-addresses) remotely
##########################################

locals {
  group_name = aws_instance.webservers[0].tags.Group
  group_ips = join("\n", [
    for a in aws_instance.webservers[*].private_ip : "${a} ansible_user=${var.user}"
  ])
  # group_data = "[${local.group_name}]\n${local.group_ips}\n"
  group_data = "[${var.env}]\n${local.group_ips}\n"
}

resource "aws_s3_bucket_object" "hosts" {
  bucket     = "terraform-state-cicd"
  key        = "hosts/${var.env}_hosts.txt"
  acl        = "private"
  content    = local.group_data
  depends_on = [aws_instance.webservers]
}

