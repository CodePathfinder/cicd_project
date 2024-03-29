#########################################
# ========= PROJECT VARIABLES ===========
#########################################

variable "project" {
  default = "CICD"
}
variable "env" {
  default = "dev"
}

#########################################
# ========= NETWORK VARIABLES ===========
#########################################

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = []
}

#########################################
# ========= INSTANCE VARIABLES ==========
#########################################

variable "key_name" {
  default = "jenkins-key-frankfurt"
}

variable "user" {
  default = "ec2-user"
}

variable "type" {
  default = "t2.micro"
}

variable "multiplier" {
  default = 2
}
