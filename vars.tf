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

# =====================================================
/*
#########################################
# ==== AUTO SCALING GROUP | AMIs MAP ====
#########################################

"10.0.20.0/24",
"10.0.21.0/24"

variable "COUNT" {
  default = 2
}

# ----------------------------------------
variable "AMIS" {
  type = map
  default = {
    ubuntu-22     = "ami-015c25ad8763b2f11"
    ubuntu-20     = "ami-02584c1c9d05efa69"
    amazon-linux  = "ami-09439f09c55136ecf"
  }
}
# ----------------------------------------

*/
