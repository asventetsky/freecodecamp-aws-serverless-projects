import boto3
import json

client = boto3.client('events')


def handler(event, context):

    scheduled_event = {
        "username": "artyom",
        "city": "Almaty",
        "age": "31"
    }
    response = client.put_events(
        Entries=[
            {
                'Source': 'lambda-reminder-event-create',
                'DetailType': 'reminder-event-create',
                'Detail': json.dumps(scheduled_event),
                'EventBusName': 'reminders-events'
            }
        ]
    )

    print(f"Response: {response}")

    return "success"
