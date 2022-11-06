import boto3


client = boto3.client('dynamodb')
table_name = "live-chat"


def handler(event, context):
    print(f"Websocket event: {event}")
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
