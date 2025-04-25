resource "aws_s3_bucket" "snapshot_bucket" {
  bucket        = var.bucket_name
}
