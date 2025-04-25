output "rds_to_s3_export_arn" {
  value = aws_iam_role.rds_to_s3_export.arn
}

output "kms_key_arn" {
  value = aws_kms_key.postgres_key.arn
}