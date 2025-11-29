variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Base name used for tagging and resource naming"
  type        = string
  default     = "secure-aws-project"
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "192.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "192.0.2.0/24" # adjust if your spec uses a different value
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the EC2 instance"
  type        = string
  default     = "74.134.83.45/32"
}

variable "instance_type" {
  description = "EC2 instance type for the Ansible target"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "Name of the EC2 key pair to use for SSH access"
  type        = string
  default     = "secure-ansible-key"
}

variable "create_eip" {
  description = "Whether to create and associate an Elastic IP with the instance"
  type        = bool
  default     = true
}
