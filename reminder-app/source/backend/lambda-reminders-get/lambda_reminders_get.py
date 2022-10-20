import boto3
import json

client = boto3.client('dynamodb')
table_name = "reminders"


def handler(event, context):
    query_parameters = event["queryStringParameters"]
    if not query_parameters:
        return construct_error_response()

    email = query_parameters['email']
    records = get_records(email)
    return construct_response(records)


def construct_error_response():
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(
            {
                "error": "Missing query parameter: email."
            }
        )
    }
    print(f"Response: {response}")
    return response


def get_records(email):
    records = client.query(
        TableName=table_name,
        IndexName="UserIdIndex",
        KeyConditionExpression='user_id = :email',
        ExpressionAttributeValues={
            ':email': {'S': email}
        }
    )

    print(f"Reminders: {records}")
    records = map_records(records)
    return records


def map_records(records):
    mapped_records = []
    for record in records['Items']:
        mapped_record = {
            "id": record['id']['S'],
            "user_id": record['user_id']['S'],
            "trigger_datetime": record['trigger_datetime']['S'],
            "notification_type": record['notification_type']['S'],
            "message": record['message']['S']
        }
        mapped_records.append(mapped_record)
    return mapped_records


def construct_response(records):
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(records)
    }
    print(f"Response: {response}")
    return response
