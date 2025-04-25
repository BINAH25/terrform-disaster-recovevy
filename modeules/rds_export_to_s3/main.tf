resource "aws_iam_role" "rds_to_s3_export" {
  name = "rds-s3-export-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "export.rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_kms_key" "postgres_key" {
  deletion_window_in_days = 10
}

resource "aws_iam_role_policy" "rds_export_policy" {
  name = "rds-export-policy"
  role = aws_iam_role.rds_to_s3_export.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*",
          "arn:aws:s3:::${var.s3_bucket_name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = aws_kms_key.postgres_key.arn
      }
    ]
  })
}


resource "aws_rds_export_task" "snapshot_export" {
  export_task_identifier = var.export_task_identifier
  source_arn             = var.snapshot_arn
  s3_bucket_name         = var.s3_bucket_name
  iam_role_arn           = aws_iam_role.rds_to_s3_export.arn
  kms_key_id             = aws_kms_key.postgres_key.arn

  depends_on = [
    aws_iam_role_policy.rds_export_policy
  ]
}


