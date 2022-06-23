#==============================================
# Data: 
#   - Availability Zones
#   - Default VPC
#   - Default Routing Table
# Provision:
#   - VPC
#   - Internet Gateway
#   - Public Subnets
#   - Private Subnets
#     - NAT Gateways
#   - Elastic Load Balancer
#   - VPC peering connection
#   - Autoscaling Group
# Outputs:
#   - main_vpc_id
#   - public_subnets_ids
#   - public_subnets_public_ips
#   - public_subnets_private_ips
#   - private_subnets_ids
#   - private_subnets_public_ips
#   - private_subnets_private_ips
#   - elastic_load_balancer_dns_name
#==============================================

###############################################
# =================== DATA ====================
###############################################

data "aws_availability_zones" "available" {}

data "aws_vpc" "default" {
  default = true
}
data "aws_route_table" "default" {
  tags = {
    Name = "default"
  }
}

###############################################
# ======== Virtual Private Cloud (VPC) ========
###############################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.env}-vpc"
    Project = var.project
  }
}

# ========== Internet Gateway (IGW) ==========

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
    Project = var.project
  }
}

###############################################
# =============== PUBLIC SUBNETS ==============
###############################################

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index +1}"
    Project = var.project
  }
}

# ====== Route table for public subnets ======

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.env}-routing-public-subnets"
    Project = var.project
  }
}

# = Associate route table with public subnets =

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}



###############################################
# ============== PRIVATE SUBNETS ==============
###############################################

# =========== Allocate elastic IPs ============

resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  vpc = true
  tags = {
    Name = "${var.env}-nat-gw-eip-${count.index + 1}"
    Project = var.project
  }
}

# ============= Add NAT gateways =============

resource "aws_nat_gateway" "nat" {
  count = length(var.private_subnet_cidrs)
  connectivity_type = "public"
  allocation_id     = aws_eip.nat[count.index].id
  subnet_id         = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
    Project = var.project
  }
}

# == Add routing tables for private subnets ==

resource "aws_route_table" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-routing-private-subnet-${count.index + 1}"
    Project = var.project
  }
}

# =========== Create private subnets ==========

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env}-private-${count.index + 1}"
    Project = var.project
  }
}

# Add associations of private subnets with nat routing tables

resource "aws_route_table_association" "private_routes" {
  count = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

###############################################
# = VPC peering connection: default <-> main ==
###############################################

# === Create default VPC <-> main VPC connection ===

resource "aws_vpc_peering_connection" "master_peering" {
  vpc_id      = aws_vpc.main.id
  peer_vpc_id = data.aws_vpc.default.id # default VPC
  auto_accept = true
  tags = {
    Name = "${var.env}-peering"
    Project = var.project
  }
} 

# == Add route -> slaves in default VPC route table ==

resource "aws_route" "jenkins_route" {
  route_table_id            = data.aws_route_table.default # default RT
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.master_peering.id
  depends_on                = [aws_vpc_peering_connection.master_peering]
}

# == Add route -> jenkins in main VPC public subnet route table ==

resource "aws_route" "slave_route" {
  route_table_id            = aws_route_table.public_subnets.id
  destination_cidr_block    = "172.31.0.0/24"  # JENKINS ADDRESS RANGE
  vpc_peering_connection_id = aws_vpc_peering_connection.master_peering.id
  depends_on                = [aws_vpc_peering_connection.master_peering]
}

/*
###############################################
# == Elastic Load Balancer (Internet-Faced) ==
###############################################

resource "aws_elb" "web" {
  name = "web-elb"
  subnets = [aws_subnet.public_subnets[*].id]
  security_groups = [aws_security_group.web.id]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 32
    target              = "HTTP:8000/"
    interval            = 30
  }
  instances = aws_instance.webserver[*].id
  cross_zone_load_balancing   = true

  tags = {
    Name = "${var.env}-web-elb"
    Project = var.project
  }
}
*/

###############################################
# ============= AUTOSCALING GROUP =============
###############################################


# ======= Create Instance Image for ASG =======



# ======== Create Launge Configuration ========



# ========= Create Autoscaling Group ==========
