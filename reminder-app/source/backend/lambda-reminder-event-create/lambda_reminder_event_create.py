import boto3
import os
from datetime import datetime
import hashlib
import json

from botocore.exceptions import ClientError

eventbridge_client = boto3.client('events')
lambda_client = boto3.client('lambda')


def handler(event, context):
    print(f"Event from DynamoDB stream: {event}")

    for record in event['Records']:
        new_obj = record['dynamodb']['NewImage']
        process_record(new_obj)

    return "success"


def process_record(record):
    details = get_details(record)

    # UTC trigger datetime
    trigger_datetime = details['trigger_datetime']
    cron_trigger_datetime = f"cron({trigger_datetime.minute} {trigger_datetime.hour} {trigger_datetime.day} {trigger_datetime.month} ? {trigger_datetime.year})"

    lambda_function_name = os.environ["lambda_function_name"]
    lambda_function_arn = os.environ["lambda_function_arn"]

    datetime_hash = hashlib.md5(cron_trigger_datetime.encode()).hexdigest()

    event_rule_details = create_schedule_event_bridge_rule(cron_trigger_datetime, datetime_hash)
    add_permission_to_invoke_lambda(lambda_function_name, event_rule_details['event_rule_arn'], datetime_hash)
    add_target_for_event_bridge_rule(lambda_function_name, lambda_function_arn, event_rule_details['event_rule_name'],
                                     details)


def get_details(record):
    notification_type = record['notification_type']['S']

    # 2011-11-04T00:05:23
    trigger_datetime_str = record['trigger_datetime']['S']
    trigger_datetime = datetime.fromisoformat(trigger_datetime_str)

    destination = record['user_id']['S']
    message = record['message']['S']

    details = {
        "notification_type": notification_type,
        "trigger_datetime": trigger_datetime,
        "destination": destination,
        "message": message
    }
    print(f"Details: {details}")

    return details


def create_schedule_event_bridge_rule(cron_trigger_datetime, datetime_hash):
    event_rule_name = f"reminders-event-rule-{datetime_hash}"

    try:
        response = eventbridge_client.put_rule(
            Name=event_rule_name,
            ScheduleExpression=cron_trigger_datetime
        )
        event_rule_arn = response['RuleArn']
        print(f"Put rule {event_rule_name} with ARN {event_rule_arn}.")
        return {
            "event_rule_name": event_rule_name,
            "event_rule_arn": event_rule_arn
        }
    except ClientError:
        print(f"Couldn't put rule {event_rule_name}.")
        raise


def add_permission_to_invoke_lambda(lambda_function_name, event_rule_arn, datetime_hash):
    try:
        lambda_client.add_permission(
            FunctionName=lambda_function_name,
            StatementId=f'{lambda_function_name}-{datetime_hash}-invoke',
            Action='lambda:InvokeFunction',
            Principal='events.amazonaws.com',
            SourceArn=event_rule_arn
        )
        print(f"Granted permission to let Amazon EventBridge call function {lambda_function_name}.")
    except ClientError:
        print(f"Couldn't add permission to let Amazon EventBridge call function {lambda_function_name}.")
        raise


def add_target_for_event_bridge_rule(lambda_function_name, lambda_function_arn, event_rule_name, details):
    destination = details['destination']
    message = details['message']

    input = {
        "destination": destination,
        "message": message
    }

    try:
        response = eventbridge_client.put_targets(
            Rule=event_rule_name,
            Targets=[
                {
                    'Id': lambda_function_name,
                    'Arn': lambda_function_arn,
                    'Input': json.dumps(input)
                }
            ]
        )
        if response['FailedEntryCount'] > 0:
            print(f"Couldn't set {lambda_function_name} as the target for {event_rule_name}.")
        else:
            print(f"Set {lambda_function_name} as the target of {event_rule_name}.")
    except ClientError:
        print(f"Couldn't set {lambda_function_name} as the target of {event_rule_name}.")
        raise
