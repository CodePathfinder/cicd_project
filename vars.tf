variable "REGION" {
  default = "eu-central-1"
}

variable "PROJECT" {
  default = "CICD"
}

variable "ENVIRONMENT" {
  default = "Dev"
}

variable "OS" {
  default = "ubuntu-20"
}

variable "TYPE" {
  default = "t2.micro"
}

variable "ZONE1" {
  default = "eu-central-1a"
}

variable "ZONE2" {
  default = "eu-central-1b"
}

variable "AMIS" {
  type = map(any)
  default = {
    ubuntu-22     = "ami-015c25ad8763b2f11"
    ubuntu-20     = "ami-02584c1c9d05efa69"
    amazon-linux  = "ami-09439f09c55136ecf"
  }
}

variable "PUB_KEY" {
  default = "jenkins-key-frankfurt.pub"
}

variable "PRIV_KEY" {
  default = "jenkins-key-frankfurt"
}

variable "MYIP" {
  default = "176.100.9.0/24"
}

variable "JenkinsSG" {
  default = "sg-0d399328d2318b1da"
}