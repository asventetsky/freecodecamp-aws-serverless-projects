import boto3
import uuid
import json

dynamodb_client = boto3.client('dynamodb')
table_name = "live-chat"


def handler(event, context):
    connection_id = event['requestContext']['connectionId']
    room_id = generate_room_id()
    create_room(connection_id, room_id)
    send_room_id(event, connection_id, room_id)
    return construct_response()


def generate_room_id():
    room_id = uuid.uuid4().hex
    print(f"Generated room_id : {room_id}")
    return room_id


def create_room(connection_id, room_id):
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


def send_room_id(event, connection_id, room_id):
    api_gateway_client = boto3.client('apigatewaymanagementapi',
                                      endpoint_url='https://' + event['requestContext']['domainName'] + '/' + event['requestContext']['stage']
                                      )

    api_gateway_client.post_to_connection(
        Data=json.dumps({"roomId": room_id}),
        ConnectionId=connection_id
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
