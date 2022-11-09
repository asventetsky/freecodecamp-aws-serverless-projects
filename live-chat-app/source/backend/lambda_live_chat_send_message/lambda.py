import boto3
import json

from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('live-chat')

dynamodb_client = boto3.client('dynamodb')
table_name = "live-chat"


def handler(event, context):
    connection_id = event['requestContext']['connectionId']
    room_id = get_room_id(connection_id)
    connection_ids = get_connection_ids(room_id)
    # send_message(connection_id, room_id)
    return construct_response()


def get_room_id(connection_id):
    response = dynamodb_client.get_item(
        TableName=table_name,
        Key={
            'connectionId': {
                'S': connection_id
            }
        }
    )
    room_id = response["Item"]["roomId"]["S"]
    print(f"room_id={room_id}")
    return room_id


def get_connection_ids(room_id):
    response = table.scan(
        FilterExpression=Attr("roomId").eq(room_id))

    connection_ids = []
    for record in response["Items"]:
        connection_id = record["connectionId"]
        connection_ids.append(connection_id)
    print(f"connection_ids={connection_ids}")
    return connection_ids


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
