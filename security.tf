# ---------------------------------------------------------------------------
# Bastion (public) security group:
#   inbound  SSH from YOUR IP only
#   outbound anywhere
# ---------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH from my IP to the bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-bastion-sg" }
}

# ---------------------------------------------------------------------------
# Private instance security group:
# TO-DO: create a security group for the private instance
#   inbound  SSH ONLY from the bastion security group (not from the internet)
#   outbound anywhere (reaches the internet via the NAT gateway)
# ---------------------------------------------------------------------------
