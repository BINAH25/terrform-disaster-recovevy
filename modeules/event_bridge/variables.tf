variable "name_prefix" {
  description = "Prefix for all named resources"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name to export RDS snapshots"
  type        = string
}

variable "kms_key" {
  description = "KMS key ARN used for snapshot encryption"
  type        = string
}

variable "lambda_file" {
  
}

variable "lambda_hash" {
  
}