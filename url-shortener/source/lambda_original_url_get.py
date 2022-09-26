import boto3

client = boto3.client('dynamodb')
table_name = "short-urls"

def lambda_handler(event, context):

    print(event)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": "success"
    }
