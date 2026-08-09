resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-terraform-s3-bucket-2026-unique"

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