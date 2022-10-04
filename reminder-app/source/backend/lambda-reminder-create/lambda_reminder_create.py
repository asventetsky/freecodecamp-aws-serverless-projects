import boto3
import hashlib
import json

client = boto3.client('dynamodb')
table_name = "reminders"


def handler(event, context):
    request = construct_request(event)
    id = generate_id(request)
    create_record(request, id)
    return construct_response(request, id)


def construct_request(event):
    body = json.loads(event['body'])
    request = {
        "user_id": body['userId'],
        "trigger_datetime": body['triggerDatetime'],
        "notification_type": body['notificationType'],
        "message": body['message']
    }

    print(f"Request: {request}")

    return request


def generate_id(request):
    id = hashlib.md5(json.dumps(request).encode()).hexdigest()
    print(f"Generated id for the record: {id}")
    return id


def create_record(request, id):
    client.put_item(
        TableName=table_name,
        Item={
            'id': {
                'S': id
            },
            'user_id': {
                'S': request['user_id']
            },
            'trigger_datetime': {
                'S': request['trigger_datetime']
            },
            'notification_type': {
                'S': request['notification_type']
            },
            'message': {
                'S': request['message']
            }
        }
    )


def construct_response(request, id):
    result = request
    result['id'] = id

    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(result)
    }
    print(f"Response: {response}")
    return response
