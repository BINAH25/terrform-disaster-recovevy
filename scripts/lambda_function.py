import boto3
def lambda_handler(event, context):
    rds = boto3.client('rds')
    autoscaling = boto3.client('autoscaling')

    replica_id = "postgres-db-replica"  
    asg_name = "dr-project-ec2-pilot-asg"

    # Step 1: Promote replica
    try:
        response = rds.promote_read_replica(DBInstanceIdentifier=replica_id)
        print("RDS Promotion successful:", response)
    except Exception as e:
        print("RDS Promotion error:", str(e))
        return {"status": "error", "message": str(e)}

    # Step 2: Scale ASG
    try:
        response = autoscaling.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            DesiredCapacity=1,
            MinSize=1
        )
        print("ASG scale-up response:", response)
    except Exception as e:
        print("ASG update error:", str(e))
        return {"status": "error", "message": str(e)}

    return {"status": "success", "message": "RDS promoted and ASG scaled"}
