import boto3
import json

client = boto3.client('dynamodb')
table_name = "short-urls"

def lambda_handler(event, context):

    hash = event['pathParameters']['hash']

    response = client.get_item(
        TableName=table_name,
        Key={
            'hash': {
                'S': hash
            }
        },
        ProjectionExpression='originalUrl'
    )

    original_url = response['Item']['originalUrl']['S']

    print(f"Original url: {original_url}")

    result = {
        'originalUrl': original_url
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(result)
    }
