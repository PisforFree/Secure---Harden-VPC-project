Secure AWS Cloud Infrastructure with Terraform, Ansible Hardening & GitHub Actions CI

This project demonstrates how to build a secure, production-style AWS environment using Terraform and then apply OS-level hardening with Ansible, all validated through a full GitHub Actions CI pipeline.

The goal of this repository is to show how modern DevOps/Cloud teams manage infrastructure:

fully automated

security-focused

tested on every commit

properly structured and linted

This project is intentionally small (one hardened EC2 instance) but designed using enterprise-grade patterns.

🚀 Project Overview

This repository provisions a hardened Ubuntu server inside a secure AWS VPC using:

Terraform for Infrastructure-as-Code

Ansible for configuration hardening

GitHub Actions for CI validation

tfsec, yamllint, and ansible-lint for security & quality checks

The pipeline ensures that every change to infrastructure or configuration is validated, scanned, linted, and syntax-checked before merging.

🏗️ Architecture Diagram (Simple Overview)
AWS Account
│
├── VPC (192.0.0.0/16)
│   ├── Public Subnet (192.0.1.0/24)
│   │   └── Hardened EC2 Instance (Ubuntu 22.04)
│   │       - IMDSv2 enforced
│   │       - Encrypted EBS volume
│   │       - SSH restricted to home IP
│   │       - Ansible hardening applied
│   │
│   └── Private Subnet (reserved for future use)
│
└── VPC Flow Logs → CloudWatch Logs (KMS-encrypted)

🧱 Infrastructure (Terraform)

Terraform builds the full AWS environment:

VPC Setup

VPC CIDR: 192.0.0.0/16

Public subnet: 192.0.1.0/24

Private subnet: 192.0.2.0/24

Internet Gateway

Route tables (public → IGW)

EC2 Instance

Ubuntu 22.04 LTS

Encrypted EBS root volume

IMDSv2 required

SSH allowed only from the developer’s home IP

Created with a dedicated SSH key (secure-ansible-key)

Logging & Security

VPC Flow Logs enabled

Logs sent to KMS-encrypted CloudWatch Log Group

Security Group includes descriptive inbound/outbound rules

You can find all infra code under:

/terraform

🔐 Server Hardening (Ansible)

After the infrastructure is created, Ansible configures and hardens the EC2 instance.

The Ansible playbook performs:

System Hardening

Full package update + security patches

Installation of security tools:

ufw firewall

fail2ban

SSH Hardening

Disable root login

Disable password authentication

Enforce key-only SSH

Disable X11 forwarding

Firewall Configuration

UFW default deny incoming

Allow only SSH (port 22)

Verification

ansible -m ping confirms connectivity

Manual validation of all hardening steps was performed

The Ansible files live under:

/ansible

🧪 Continuous Integration (GitHub Actions)

Every push and pull request triggers a full CI pipeline that validates both Terraform and Ansible.

🔍 Terraform CI Steps

terraform fmt -check

terraform init -backend=false
(avoids requiring AWS creds during CI)

terraform validate

tfsec security scanning

🔧 Ansible CI Steps

yamllint → YAML style validation

Ansible syntax check (ansible-playbook --syntax-check)

ansible-lint → best-practice + security linting

CI file located at:

/.github/workflows/ci.yml


This ensures no broken or insecure IaC/config ever gets merged.

📁 Project Structure
secure_harden-vpc-proj/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── provider.tf
│   ├── backend.tf
│   ├── logging.tf
│   ├── outputs.tf
│   └── secure-ansible-key.pem (ignored)
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   └── playbook.yml
│
└── .github/workflows/
    └── ci.yml

🛡️ Security Highlights

This project includes multiple real-world security best practices:

IMDSv2 enforced

All EBS volumes encrypted

Flow logs enabled (CloudTrail-style visibility for VPC traffic)

tfsec scanning on every commit

ansible-lint enforcing hardening correctness

yamllint enforcing configuration hygiene

SSH exposure restricted to a single trusted IP

Firewall and fail2ban active on the instance

This is the kind of baseline a DevSecOps team would want for EC2-based infrastructure.

🎯 Why This Project Matters

This repository demonstrates hands-on experience with:

Cloud security

Infrastructure automation

CI/CD pipelines

Configuration management

AWS networking fundamentals

Linting and static analysis

Terraform best practices

Ansible hardening workflows

It’s intentionally structured to look like something used in an engineering team, not a school project.

📝 How to Reproduce
1. Clone the repository
git clone https://github.com/<your-username>/secure_harden-vpc-proj.git

2. Deploy infrastructure
cd terraform
terraform init
terraform apply

3. Run Ansible hardening
cd ansible
ansible-playbook playbook.yml -i inventory.ini

📜 License

MIT License — free to use, modify, and learn from.

🙌 Contributions

Issues and pull requests are welcome.
This repo exists so other engineers can learn from or build on secure IaC practices.