import boto3
import hashlib
import json

client = boto3.client('dynamodb')
table_name = "short-urls"

def lambda_handler(event, context):

    originalUrl = json.loads(event['body'])['originalUrl']
    print(f"Original url: {originalUrl}")

    hash = hashlib.md5(originalUrl.encode()).hexdigest()
    print(f"Generated hash for original url: {hash}")

    client.put_item(
        TableName=table_name,
        Item={
            'hash': {
                'S': hash
            },
            'originalUrl': {
                'S': originalUrl
            }
        }
    )

    # resourcePath is already contains slash
    serviceUrl = f"https://{event['headers']['Host']}/{event['requestContext']['stage']}{event['requestContext']['resourcePath']}"

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": f"{serviceUrl}/{hash}"
    }
