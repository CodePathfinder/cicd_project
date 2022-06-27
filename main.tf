# ==== Providers configuration: AWS ====
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
}

# ========== dev-environment ===========

module "network" {
  source               = "./aws_modules/network"
  env                  = "dev"
  public_subnet_cidrs  = ["10.0.10.0/24"]
  private_subnet_cidrs = []
}

module "instances" {
  source     = "./aws_modules/instances"
  vpcid      = module.network.vpc_id # takes value for output
  public_ids = module.network.public_subnet_ids
  env        = "dev"
  user       = "ubuntu"
}

# ============== outputs ==============

output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr_block" {
  value = module.network.cidr_block
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "hosts" {
  value = module.instances.hosts
}

output "public_ips" {
  value = module.instances.public_ips
}
/*
output "load_balancer_url" {
  value = module.instances.load_balancer_url
}

# ==============================

data "terraform-remote-state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-cicd"
    key    = "terraform/backend"
    region = "eu-central-1"
  }
}

output "network_details" {
  value = data.terraform-remote-state.network
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
