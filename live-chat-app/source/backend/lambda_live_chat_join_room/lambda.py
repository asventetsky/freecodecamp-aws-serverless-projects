import boto3
import json

dynamodb_client = boto3.client('dynamodb')
table_name = "live-chat"


def handler(event, context):
    connection_id = event['requestContext']['connectionId']
    room_id = extract_room_id(event)
    join_room(connection_id, room_id)
    return construct_response()


def extract_room_id(event):
    room_id = json.loads(event['body'])['roomId']
    return room_id


def join_room(connection_id, room_id):
    dynamodb_client.put_item(
        TableName=table_name,
        Item={
            'connectionId': {
                'S': connection_id
            },
            'roomId': {
                'S': room_id
            }
        }
    )


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
