#########################################
# MODULED TERRAFORMR | VARIABLES (INPUT)
#########################################

variable "project" {
  default = "CICD"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.10.0",
    "10.0.11.0"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.20.0",
    "10.0.21.0"
  ]
}

# =====================================================
/*
#########################################
# INSTANCE: COUNT | OS | TYPE | KEY-PAIR 
#########################################

variable "COUNT" {
  default = 2
}

variable "OS" {
  default = "ubuntu-20"
}

variable "TYPE" {
  default = "t2.micro"
}

variable "USER" {
  default = "ubuntu"
}

variable "PUB_KEY" {
  default = "jenkins-key-frankfurt.pub"
}

variable "PRIV_KEY" {
  default = "jenkins-key-frankfurt"
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

#########################################
# NETWORKING: SSH INGRESS CIDR 
#########################################

variable "SSH_CIDR" {
  default = "all_ip"
}

variable "IP_ADDRESSES" {
  type = map
  default = {
    my_ip       = "176.100.9.0/24"
    all_ip      = "0.0.0.0/0"
    jenkins_ip  = "172.31.0.225/32"
  }
}

#########################################
# EXISTING RESOURCES 
#########################################
*/