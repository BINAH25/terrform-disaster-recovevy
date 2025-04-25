resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "rds_export_role" {
  name = "${var.name_prefix}-rds-export-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "export_snapshot" {
  filename         = var.lambda_file
  function_name    = "${var.name_prefix}-export-snapshot"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = var.lambda_hash

  environment {
    variables = {
      S3_BUCKET       = var.s3_bucket
      KMS_KEY         = var.kms_key
      EXPORT_ROLE_ARN = aws_iam_role.rds_export_role.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "rds_snapshot_created" {
  name        = "${var.name_prefix}-snapshot-rule"
  description = "Triggers Lambda on RDS snapshot creation"
  event_pattern = jsonencode({
    source = ["aws.rds"],
    "detail-type" = ["RDS DB Snapshot Event"],
    detail = {
      EventCategories = ["creation"]
    }
  })
}

resource "aws_cloudwatch_event_target" "rds_event_target" {
  rule      = aws_cloudwatch_event_rule.rds_snapshot_created.name
  target_id = "rds-export-lambda"
  arn       = aws_lambda_function.export_snapshot.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.export_snapshot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_snapshot_created.arn
}
