import boto3

from botocore.exceptions import ClientError

client = boto3.client('dynamodb')
table_name = "live-chat"


def handler(event, context):
    connection_id = event['requestContext']['connectionId']

    try:
        client.put_item(
            TableName=table_name,
            Item={
                'connectionId': {
                    'S': connection_id
                }
            }
        )
    except ClientError:
        print(f"Couldn't put connection_id={connection_id}.")
        raise

    return construct_response()


def construct_response():
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type"
        }
    }
    return response
