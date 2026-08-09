variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix applied to every resource, so they are easy to find and delete."
  type        = string
  default     = "tf-network-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for both instances. t3.micro is Free Tier eligible in most regions."
  type        = string
  default     = "t3.micro"
}

# No default on purpose: you must supply your own IP so SSH is never open to the world.
variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation, e.g. 203.0.113.4/32. Only this address may SSH to the bastion."
  type        = string
   default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be valid CIDR notation, for example 203.0.113.4/32."
  }
}
