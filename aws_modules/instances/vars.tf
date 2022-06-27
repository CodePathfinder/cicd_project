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

#########################################
# ========= IMPORTED VARIABLES ==========
#########################################

variable "vpcid" {
  description = "ID of the VPC in which security resources are deployed"
  type        = string
}
