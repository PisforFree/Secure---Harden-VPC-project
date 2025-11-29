terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  # Optional but recommended
  default_tags {
    tags = {
      Project = "secure-harden-vpc-proj"
      Managed = "terraform"
    }
  }
}
