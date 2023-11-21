variable "cloudtruth_api_key" {
  type        = string
  description = "The CloudTruth API key to"
}

variable "cluster_config" {
  type        = string
  description = "example terraform input variable"
  default = "defaultClusterConfig"
}

variable "region_config" {
  type        = string
  description = "example terraform input variable"
  default = "defaultRegionConfig"
}

locals {
  env = terraform.workspace
  provision_ct_params = local.env == "development" ? true : false
}

provider "cloudtruth" {
  api_key = var.cloudtruth_api_key
  project = "bridge-terraform-argocd"
  environment = local.env
}


resource "aws_s3_bucket" "app-bucket" {
  bucket        = "cloudtruth-webinar-bridge-app-${local.env}"
}

resource "aws_kms_key" "app-key" {
  description = "KMS key for app"
}

resource "cloudtruth_parameter" "app-bucket-name" {
  count = local.provision_ct_params ? 1 : 0
  name = "app_bucket_name"
}
resource "cloudtruth_parameter_value" "app-bucket-name" {
  depends_on = [
    cloudtruth_parameter.app-bucket-name
  ]
  parameter_name = "app_bucket_name"
  environment = local.env
  value = aws_s3_bucket.app-bucket.bucket
}

resource "cloudtruth_parameter" "app-bucket-arn" {
  count = local.provision_ct_params ? 1 : 0
  name = "app_bucket_arn"
}
resource "cloudtruth_parameter_value" "app-bucket-arn" {
  depends_on = [
    cloudtruth_parameter.app-bucket-arn
  ]
  parameter_name = "app_bucket_arn"
  environment = local.env
  value = aws_s3_bucket.app-bucket.arn
}

resource "cloudtruth_parameter" "app-key-arn" {
  count = local.provision_ct_params ? 1 : 0
  name = "app_key_arn"
}
resource "cloudtruth_parameter_value" "app-key-arn" {
  depends_on = [
    cloudtruth_parameter.app-key-arn
  ]
  parameter_name = "app_key_arn"
  environment = local.env
  value = aws_kms_key.app-key.arn
}

resource "cloudtruth_parameter" "app-tf-secret" {
  count = local.provision_ct_params ? 1 : 0
  name = "app_tf_secret"
  secret = true
}
resource "cloudtruth_parameter_value" "app-tf-secret" {
  depends_on = [
    cloudtruth_parameter.app-tf-secret
  ]
  parameter_name = "app_tf_secret"
  environment = local.env
  value = timestamp()
}

# resource "cloudtruth_parameter" "app-tf-other-secret" {
#   count = local.provision_ct_params ? 1 : 0
#   name = "app_tf_other_secret"
#   secret = true
# }
# resource "cloudtruth_parameter_value" "app-tf-other-secret" {
#   depends_on = [
#     cloudtruth_parameter.app-tf-other-secret
#   ]
#   parameter_name = "app_tf_other_secret"
#   environment = local.env
#   value = timestamp()
# }

output "cluster_config" {
  value = var.cluster_config
}
output "region_config" {
  value = var.region_config
}
output "app_bucket_arn" {
  value = aws_s3_bucket.app-bucket.arn
}
output "app_key_arn" {
  value = aws_kms_key.app-key.arn
}
