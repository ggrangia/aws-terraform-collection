resource "aws_s3_bucket" "bucket" {
  count = var.create_bucket ? 1 : 0

  bucket = "some-bucket-123456"
}
