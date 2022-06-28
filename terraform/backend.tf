terraform {
  backend "s3" {
    bucket = "daniel-oliveira-tf-state"
    key    = "devops-challange/terraform.tfstate"
    region = "us-west-2"
  }
}