output "db_hostname" {
  value = aws_db_instance.postgres.address
}

output "db_instance_arn" {
  value = var.replicate_from_primary ? aws_db_instance.replica[0].arn : aws_db_instance.postgres[0].arn
}
