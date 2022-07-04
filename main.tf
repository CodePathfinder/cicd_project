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
  vpcid      = module.network.vpc_id
  public_ids = module.network.public_subnet_ids
  env        = "dev"
  user       = "ubuntu"
}

# ========== prod-environment ===========
module "network_prod" {
  source               = "./aws_modules/network"
  vpc_cidr             = "10.1.0.0/16"
  env                  = "prod"
  public_subnet_cidrs  = ["10.1.10.0/24", "10.1.11.0/24"]
  private_subnet_cidrs = ["10.1.20.0/24", "10.1.21.0/24"]
}

module "instances_prod" {
  source     = "./aws_modules/instances"
  vpcid      = module.network_prod.vpc_id
  public_ids = module.network_prod.public_subnet_ids
  env        = "prod"
  user       = "ec2-user"
}


# ============== dev-outputs ==============

output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr_block" {
  value = module.network.vpc_cidr
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

output "load_balancer_url" {
  value = module.instances.load_balancer_url
}

# ============== prod-outputs ==============

output "vpc_id_prod" {
  value = module.network_prod.vpc_id
}

output "vpc_cidr_block_prod" {
  value = module.network_prod.vpc_cidr
}

output "public_subnet_ids_prod" {
  value = module.network_prod.public_subnet_ids
}

output "hosts_prod" {
  value = module.instances_prod.hosts
}

output "public_ips_prod" {
  value = module.instances_prod.public_ips
}

output "load_balancer_url_prod" {
  value = module.instances_prod.load_balancer_url
}
/*
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
