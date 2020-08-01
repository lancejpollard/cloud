
terraform {
  required_version = ">= 0.12"
  
  required_providers {
    aws = "~> 3.0.0"
  }
}

provider "aws" {
  region = "us-west-1"
}

module "staging" {
  environment = "staging"
  source = "./staging"
}

module "production" {
  environment = "production"
  source = "./production"
}
