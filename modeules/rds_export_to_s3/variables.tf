# ---------- VARIABLES ----------
variable "export_task_identifier" {
  description = "Unique identifier for the export task"
  type        = string
}

variable "snapshot_arn" {
  description = "ARN of the RDS snapshot to export"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name where snapshot export will be stored"
  type        = string
}

