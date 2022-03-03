terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}

terraform {
    backend "s3" {
        bucket = "ks-terraform-state-s3-bucket"
        key    = "terraform/remote/s3/terraform.tfstate"
        dynamodb_table = "dynamodb-terraform-state-locking"
        region = "us-east-1"
    }
}
