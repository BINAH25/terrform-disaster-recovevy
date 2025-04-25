output "db_hostname" {
  value = aws_db_instance.postgres.address
}

output "db_instance_arn" {
  value = aws_db_instance.postgres.arn
}

output "db_snapshot_arn" {
  value = aws_db_snapshot.postgres_snap.db_snapshot_arn
}