
resource "aws_s3_bucket" "dynamic_maps" {
  bucket = "metaflow-test-123qwsa"
}

resource "aws_s3_bucket_acl" "dynamic_maps" {
  bucket = aws_s3_bucket.dynamic_maps.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.dynamic_maps]
}

resource "aws_s3_bucket_versioning" "dynamic_maps" {
  bucket = aws_s3_bucket.dynamic_maps.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "dynamic_maps" {
  bucket = aws_s3_bucket.dynamic_maps.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "dynamic_maps" {
  bucket                  = aws_s3_bucket.dynamic_maps.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
