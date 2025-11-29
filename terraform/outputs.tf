########################################
# Core network outputs
########################################

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

########################################
# EC2 instance outputs
########################################

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.web.private_ip
}

# If create_eip = true, this gives the EIP; otherwise, the normal public IP
output "ec2_public_ip" {
  description = "Public IP address to SSH into the EC2 instance"
  value       = var.create_eip ? aws_eip.web_eip[0].public_ip : aws_instance.web.public_ip
}

# Convenience: full SSH command
output "ssh_command" {
  description = "Convenience SSH command to connect to the EC2 instance"
  value       = "ssh -i ./secure-ansible-key.pem ubuntu@${var.create_eip ? aws_eip.web_eip[0].public_ip : aws_instance.web.public_ip}"
}
