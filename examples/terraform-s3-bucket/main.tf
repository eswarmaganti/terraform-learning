

resource "random_string" "this" {
  length  = 8
  upper   = false
  special = false
}

# Create the S3 Bucket for remote backend
resource "aws_s3_bucket" "this" {
  bucket = format("%s-%s", var.bucket_name, random_string.this.result)
  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

