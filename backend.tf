terraform {
  backend "s3" {
    bucket       = "my-terraform-s3-bucket-2026-unique"
    key          = "aws-terraform-network-lab/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = false
    encrypt      = true
  }
}