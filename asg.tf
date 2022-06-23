# ===========================================================
# Provision Highly Available Web in any Region Default VPC
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


###############################################
# ============== COLLECT DATA =================
###############################################

data "aws_availability_zones" "available" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

# ================= AMI Lookup ================

data "aws_ami" "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "amazon_linux_latest" {
  owners = ["amazon"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

###############################################
# ==== Create 'web-server' security group =====
###############################################

resource "aws_security_group" "web" {
#  vpc_id      = aws_vpc.main.id
  name        = "Web SG"
  description = "Web Dynamic SG: open ports 80, 443"

  dynamic "ingress" {
	for_each = ["80", "443"]
	content = {
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
    Name = "${var.env}-web-sg"
    Project = var.project
  }
}

###############################################
# ============= AUTOSCALING GROUP =============
###############################################

# ======== Create Launge Configuration ========

resource "aws_launch_configuration" "web" {
  name_prefix   = "web-config-"
  image_id      = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"
  security groups = [aws_security_group.web.id]
  user_data = file("web.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# ========= Create Autoscaling Group ==========

resource "aws_autoscaling_group" "web" {
  name                 = "web-asg"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type     = "ELB"
  vpc_zone_identifier   = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
# vpc_zone_identifier = [aws_subnet.example1.id, aws_subnet.example2.id]
  load_balancers        = [aws_elb.web.name]
  
  lifecycle {
    create_before_destroy = true
  }
  
  dynamic "tag" {
	for_each = {
		Name = "WebServer-in-ASG"
		Project = "var.project"
	}
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

###############################################
# == Elastic Load Balancer (Internet-Faced) ==
###############################################

resource "aws_elb" "web" {
  name = "web-elb"
  security_groups = [aws_security_group.web.id]
  availability_zones = # may be replaced with subnets 
  [
	data.aws_availability_zones.available.names[0],
	data.aws_availability_zones.available.names[1],
  ] 
/*
  subnets = [aws_subnet.public_subnets[*].id]
  access_logs {
    bucket        = "my_project_cicd"
    bucket_prefix = "elb_access_logs"
    interval      = 60
  }
*/
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances = aws_instance.webserver[*].id
  cross_zone_load_balancing   = true

  tags = {
    Name = "${var.env}-web-elb"
    Project = var.project
  }
}
