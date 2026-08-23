resource "aws_s3_bucket" "my_bucket" {
  bucket = "npp2024-terraform-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "My Terraform S3 Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}