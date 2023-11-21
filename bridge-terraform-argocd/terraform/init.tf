terraform {
  required_version = "1.6.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudtruth = {
      source = "cloudtruth/cloudtruth"
      version = "0.5.11"
    }
  }

  backend "s3" {
    bucket = "cloudtruth-webinar-bridge-state"
    key    = "terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "cloudtruth-webinar-bridge-state"
  }
}

provider "aws" {
  region = "us-east-1"
  # profile from AWS_PROFILE environment variable
}
