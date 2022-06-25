# ==== Providers configuration: AWS ====

provider "aws" {
  region = "eu-central-1"
}

# ========== dev-environment ===========

module "main-vpc" {
  source               = "./aws_modules/network"
  env                  = "dev"
  public_subnet_cidrs  = ["10.0.10.0/24"]
  private_subnet_cidrs = []
}

module "ec2-elb-sg" {
  source = "./aws_modules/instances"
  env    = "dev"
  user   = "ubuntu"
}

# ========== prod-environment ==========
/*
module "main-vpc" {
  source               = "./aws_modules/network"
  env                  = "prod"
  private_subnet_cidrs = []
}

module "ec2-elb-sg" {
  source = "./aws_modules/instances"
  env    = "prod"
  user   = "ubuntu"
  type   = "t2.small"
}
*/
# ============== outputs ==============

output "vpc_cidr_block" {
  value = module.main-vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.main-vpc.public_subnet_ids
}

output "hosts" {
  value = module.ec2-elb-sg.hosts
}

output "public_ips" {
  value = module.ec2-elb-sg.public_ips
}

output "load_balancer_url" {
  value = module.ec2-elb-sg.load_balancer_url
}

