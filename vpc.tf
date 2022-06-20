##########################################
# == Create Virtual Private Cloud (VPC) ==
##########################################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "main-vpc"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}

##########################################
# === Associate main-vpc with jenkins ===
##########################################
resource "aws_vpc_peering_connection" "default-main-vpcs" {
  vpc_id      = aws_vpc.main.id
  peer_vpc_id = "vpc-0dd796b7b6beec76f"
  auto_accept = true
}

#########################################
# ======== CREATE PUBLIC SUBNET =========
#########################################

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-a"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}

#########################################
# == Add internet gateway (IGW) to VPC ==
#########################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}

#########################################
#  Add routing to IGW for public subnet
#########################################

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}

#########################################
#  Associate public subnet with public-rt
#########################################

resource "aws_route_table_association" "public_rt_association_a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public-rt.id
}

#########################################
#  Elastic Load Balancer (Internet-Faced)
#########################################

resource "aws_elb" "web" {
  name = "web-elb"
  subnets = [aws_subnet.public-a.id]
  security_groups = [aws_security_group.allow-web.id]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  instances = aws_instance.webserver[*].id
  tags = {
    Name = "web-elb"
    Project = var.PROJECT
    Environment = var.ENVIRONMENT
  }
}
