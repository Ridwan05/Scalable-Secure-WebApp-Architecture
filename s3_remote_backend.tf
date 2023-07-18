# Create S3 bucket
resource "aws_s3_bucket" "tf-backend" {
  bucket        = "ridtf-backend"
  force_destroy = true

  tags = {
    Name        = "ridtf-backend"
    Environment = "Dev"
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "versioning_tf-bucket" {
  bucket = aws_s3_bucket.tf-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block Public Access to bucket 
resource "aws_s3_bucket_public_access_block" "bucket-public-block" {
  bucket = aws_s3_bucket.tf-backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create dynamodb table to lock remote backend file
resource "aws_dynamodb_table" "tf-lock-table" {
  name         = "ridtf-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}