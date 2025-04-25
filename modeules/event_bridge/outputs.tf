output "lambda_function_arn" {
  value = aws_lambda_function.export_snapshot.arn
}

output "eventbridge_rule" {
  value = aws_cloudwatch_event_rule.rds_snapshot_created.name
}
