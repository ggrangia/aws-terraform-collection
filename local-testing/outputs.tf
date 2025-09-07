output "s3_bucket_name" {
  value = try(aws_s3_bucket.bucket[0].bucket, null)
}
