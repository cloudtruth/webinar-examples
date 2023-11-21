terraform {
  required_version = "1.6.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # profile from AWS_PROFILE environment variable
}

resource "aws_s3_bucket" "state" {
  bucket        = "cloudtruth-webinar-bridge-state"

    # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "state-public-access" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "state-lock-table" {
  name           = "cloudtruth-webinar-bridge-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

variable "cloudtruth_aws_integration_external_id" {
  type        = string
  description = "External ID from cloudtruth integration"
}

module "grant-cloudtruth-access" {
  source = "github.com/cloudtruth/terraform-cloudtruth-access"
  role_name = "cloudtruth-webinars"
  external_id = var.cloudtruth_aws_integration_external_id
  account_ids = ["609878994716"]
  services_enabled = ["s3"]
  services_write_enabled = []
  s3_resources     = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]
  ssm_resources = []
  secretsmanager_resources = []
}
