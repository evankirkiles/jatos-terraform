/*
 * main.tf
 * author: evan kirkiles
 * created on Sat Mar 04 2023
 * 2023 the nobot space, 
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  // add s3 backend
  backend "s3" {
    bucket = "terraform-jatos"   // <-- should be replaced for your AWS S3 backend
    key    = "terraform.tfstate" // <-- set to some special sandbox key
    region = "us-east-1"
  }
}

locals {
  prefix = "jatos-${var.prefix}"
}

/* ----------------------------- Provider setup ----------------------------- */

// Supply your credentials to the AWS provider using environment variables,
// either AWS_PROFILE or AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      JATOS = 1
    }
  }
}

/* -------------------------------- AWS Data -------------------------------- */

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}