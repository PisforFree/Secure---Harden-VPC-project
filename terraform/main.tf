########################################
# Network: VPC, Public + Private Subnets, IGW, Routes
########################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# ---------------------
# Public Subnet
# ---------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
    Tier        = "public"
  }
}

# ---------------------
# Private Subnet
# ---------------------
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Environment = var.environment
    Tier        = "private"
  }
}

# ---------------------
# Internet Gateway (public subnet needs it)
# ---------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# ---------------------
# Public Route Table (IGW → 0.0.0.0/0)
# ---------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------
# Private Route Table (no IGW, no NAT)
# ---------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


########################################
# Security Group for EC2
########################################

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for hardened EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic for updates and package installs"
    # tfsec:ignore:aws-ec2-no-public-egress-sgr
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}

########################################
# Ubuntu AMI (data source)
########################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

########################################
# EC2 Instance
########################################

########################################
# SSH Key Pair (from local public key)
########################################

resource "aws_key_pair" "ansible_key" {
  key_name   = var.ssh_key_name
  public_key = file("${path.module}/secure-ansible-key.pub")
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.ssh_key_name

  # Encrypt the root EBS volume at rest
  root_block_device {
    encrypted = true
  }

  # Extra hardening: enforce IMDSv2 (optional but good practice)
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
  }
}

########################################
# Optional Elastic IP
########################################

resource "aws_eip" "web_eip" {
  count = var.create_eip ? 1 : 0

  domain   = "vpc"
  instance = aws_instance.web.id

  tags = {
    Name        = "${var.project_name}-eip"
    Environment = var.environment
  }
}
