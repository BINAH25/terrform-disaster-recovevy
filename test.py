import boto3
import json
from botocore.exceptions import BotoCoreError, ClientError

def get_database_credentials():
    secret_name = "dr-project-secret-us-east-2"  # Use the correct secret name
    region_name = "us-east-2"  # Ensure the region is correct

    # Create a Secrets Manager client
    client = boto3.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        response = client.get_secret_value(SecretId=secret_name)

        if 'SecretString' in response:
            secrets = json.loads(response['SecretString'])

            print("Database Credentials:")
            print(f"Host: {secrets.get('host', 'N/A')}")
            print(f"Database: {secrets.get('dbname', 'N/A')}")
            print(f"User: {secrets.get('username', 'N/A')}")
            print(f"Password: {secrets.get('password', 'N/A')}")
            print(f"Port: {secrets.get('port', 'N/A')}")
        else:
            print("No secret string found.")
    except (BotoCoreError, ClientError) as e:
        print(f"Secrets Manager Error: {e}")

# Call the function to print credentials
get_database_credentials()
