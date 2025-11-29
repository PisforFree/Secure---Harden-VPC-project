terraform {
  backend "s3" {
    bucket         = "secure-harden-vpc-tfstate"
    key            = "secure-harden-vpc/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "secure-harden-vpc-tf-locks"
    encrypt        = true
  }
}
