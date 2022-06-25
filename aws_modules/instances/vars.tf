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
