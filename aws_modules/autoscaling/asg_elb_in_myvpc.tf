# ===========================================================
# Provision Highly Available Web in My VPC
# Data:
#   - Availability Zones
#   - AMI Lookup
#   - Default Subnets' IDs as 'resource'
# Create:
#   - Security Group for Web Server
#   - Launch Configurations with Auto AMI Lookup
#   - Auto Scaling Group using 2 Availability Zones
#   - Classic Load Balancer in 2 Availability Zones
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
  vpc_id      = aws_vpc.main.id
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
  vpc_id      = aws_vpc.main.id
  name        = "web_sg"
  description = "Allow http inbound traffic from anywhere"

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "${var.env}-web-sg"
    Project = var.project
  }
}

###############################################
# ============= AUTOSCALING GROUP =============
###############################################

# ======== Create Launge Configuration ========

resource "aws_launch_configuration" "web" {
  name_prefix   = "web-config-"
  image_id      = var.user == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.amazon_linux.id
  instance_type = var.type
  security_groups = [
    aws_security_group.web.id,
    aws_security_group.ssh.id
  ]
  associate_public_ip_address = true
  user_data                   = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# ========= Create Autoscaling Group ==========

resource "aws_autoscaling_group" "web" {
  name                 = "web-asg-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = aws_subnet.public_subnets[*].id
  load_balancers       = [aws_elb.web.name]

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = {
      Name    = "Web-in-ASG"
      Project = var.project
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

###############################################
# ========== Classic Load Balancer ============
###############################################

resource "aws_elb" "web" {
  name            = "web-elb"
  security_groups = [aws_security_group.web.id]
  subnets         = aws_subnet.public_subnets[*].id

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
  cross_zone_load_balancing = true

  tags = {
    Name    = "${var.env}-web-elb"
    Project = var.project
  }
}

###############################################
# ================== OUTPUTS ==================
###############################################

output "Load_Balancer_URL" {
  value = aws_elb.web.dns_name
}
