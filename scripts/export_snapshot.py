import boto3
import os

def lambda_handler(event, context):
    snapshot_arn = event['detail']['SourceArn']
    export_task_id = "export-" + snapshot_arn.split(":")[-1].replace(":", "-")
    s3_bucket = os.environ['S3_BUCKET']
    kms_key = os.environ['KMS_KEY']
    role_arn = os.environ['EXPORT_ROLE_ARN']

    rds = boto3.client('rds')

    rds.start_export_task(
        ExportTaskIdentifier=export_task_id,
        SourceArn=snapshot_arn,
        S3BucketName=s3_bucket,
        IamRoleArn=role_arn,
        KmsKeyId=kms_key
    )
