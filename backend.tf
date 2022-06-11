terraform {
  backend "s3" {
    bucket = "terraform-state-cicd"
    key    = "terraform/backend"
    region = "eu-central-1"
  }
}
