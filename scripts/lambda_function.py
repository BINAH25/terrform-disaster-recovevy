import boto3

def lambda_handler(event, context):
    rds = boto3.client('rds')

    replica_id = "postgres-db-replica"

    try:
        response = rds.promote_read_replica(
            DBInstanceIdentifier=replica_id
        )
        print("Promote call response:", response)
        return {"status": "success", "message": "Replica promoted"}
    except Exception as e:
        print("Error:", str(e))
        return {"status": "error", "message": str(e)}
