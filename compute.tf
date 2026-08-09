# ---------------------------------------------------------------------------
# SSH key pair
# Terraform generates a fresh key so students do not have to create one by hand.
# The private key is written to a .pem file in this folder (git-ignored).
# ---------------------------------------------------------------------------
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}

# ---------------------------------------------------------------------------
# Latest Amazon Linux 2023 AMI for the chosen region (no hard-coded AMI IDs).
# ---------------------------------------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ---------------------------------------------------------------------------
# Bastion host in the PUBLIC subnet (has a public IP, reachable from your IP).
# ---------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = { Name = "${var.project_name}-bastion" }
}

# ---------------------------------------------------------------------------
# Application host in the PRIVATE subnet (no public IP, reachable only via the
# bastion; reaches the internet outbound through the NAT gateway).
# ---------------------------------------------------------------------------
resource "aws_instance" "private" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = aws_key_pair.this.key_name

  user_data = <<-EOF
               #!/bin/bash
               dnf update -y
               dnf install -y httpd
               systemctl enable httpd
               systemctl start httpd
               echo "<h1>Private Web Server</h1>" > /var/www/html/index.html
               echo "<p>Hostname: $(hostname)</p>" >> /var/www/html/index.html
               EOF



  tags = { Name = "${var.project_name}-private" }
}
