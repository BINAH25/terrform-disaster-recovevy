import boto3
import time
import json

rds = boto3.client('rds')
secretsmanager = boto3.client('secretsmanager')
autoscaling = boto3.client('autoscaling')

replica_id = "postgres-db-replica"
asg_name = "dr-project-ec2-pilot-asg"
secret_name = "dr-project-secret-key-us-east-1"

def lambda_handler(event, context):
    try:
        # Step 1: Promote Read Replica
        print("Promoting replica...")
        rds.promote_read_replica(DBInstanceIdentifier=replica_id)
        print("⏳ Waiting for RDS promotion to complete...")

        # Wait until the replica becomes an independent 'available' instance
        waiter = rds.get_waiter('db_instance_available')
        waiter.wait(DBInstanceIdentifier=replica_id, WaiterConfig={'Delay': 30, 'MaxAttempts': 10})
        print("✅ Replica promoted successfully.")

        # Step 2: Describe instance to get endpoint info
        db_info = rds.describe_db_instances(DBInstanceIdentifier=replica_id)
        endpoint = db_info["DBInstances"][0]["Endpoint"]["Address"]
        print("Endpoint:", endpoint)

        # Step 3: Create Secret
        secret_payload = {
            "username": "louis",
            "password": "Louis123", 
            "host": endpoint,
            "port": 5432,
            "dbname": "file_server"
        }

        try:
            print("Creating secret...")
            secretsmanager.update_secret(
                SecretId=secret_name,
                SecretString=json.dumps(secret_payload)
            )
            print(f"✅ Secret '{secret_name}' created.")
        except secretsmanager.exceptions.ResourceExistsException:
            print(f"⚠️ Secret '{secret_name}' already exists. Updating instead.")
            secretsmanager.update_secret(
                SecretId=secret_name,
                SecretString=json.dumps(secret_payload)
            )

        # Step 4: Scale ASG
        print("Scaling ASG...")
        autoscaling.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=1,
            MinSize=1
        )
        print("✅ ASG scaled up.")

        return {"status": "success", "message": "RDS promoted, secret created, ASG scaled."}

    except Exception as e:
        print("❌ Error:", str(e))
        return {"status": "error", "message": str(e)}
