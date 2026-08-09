output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet."
  value       = aws_subnet.private.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host."
  value       = aws_instance.bastion.public_ip
}

output "private_instance_private_ip" {
  description = "Private IP of the instance in the private subnet."
  value       = aws_instance.private.private_ip
}

output "key_file" {
  description = "Path to the generated private key on your machine."
  value       = local_sensitive_file.private_key.filename
}

# Copy and paste these directly into your terminal.
output "ssh_to_bastion" {
  description = "SSH into the bastion (public) host."
  value       = "ssh -i ${local_sensitive_file.private_key.filename} ec2-user@${aws_instance.bastion.public_ip}"
}

output "ssh_to_private" {
  description = "SSH into the private host, jumping through the bastion."
  value       = "ssh -i ${local_sensitive_file.private_key.filename} -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.private.private_ip}"
}
output "s3_bucket" {
  description = "My-bucket"
  value       =  aws_s3_bucket.my_bucket.id
}
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}