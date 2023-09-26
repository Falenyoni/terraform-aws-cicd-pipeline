terraform {
  backend "s3" {
    bucket = "fn-terraform-aws-cicd-pipeline"
    encrypt = true
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}