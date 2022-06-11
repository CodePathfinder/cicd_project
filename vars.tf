#########################################
# REGION | PROJECT | ENVIRONMENT | ZONES
#########################################

variable "PROJECT" {
  default = "CICD"
}

variable "ENVIRONMENT" {
  default = "Dev"
}

variable "REGION" {
  default = "eu-central-1"
}

variable "ZONE1" {
  default = "eu-central-1a"
}

variable "ZONE2" {
  default = "eu-central-1b"
}

#########################################
# INSTANCE: OS | TYPE | KEY-PAIR 
#########################################

variable "OS" {
  default = "ubuntu-20"
}

variable "TYPE" {
  default = "t2.micro"
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

variable "JenkinsSG" {
  default = "sg-0d399328d2318b1da"
}