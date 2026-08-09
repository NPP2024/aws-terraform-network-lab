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
# ---------------------------------------------------------------------------
# Private instance security group
# ---------------------------------------------------------------------------
resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-sg"
  description = "Security group for private EC2 instance"
  vpc_id      = aws_vpc.this.id

  # Allow SSH only from the bastion host
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
 # HTTP from bastion
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-sg"
  }
}