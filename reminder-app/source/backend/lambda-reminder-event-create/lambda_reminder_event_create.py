import boto3
import os
import datetime

from botocore.exceptions import ClientError

eventbridge_client = boto3.client('events')
lambda_client = boto3.client('lambda')


def handler(event, context):

    print(f"Event from DynamoDB stream: {event}")
    record = event['Records'][0]
    if

    ['dynamodb']['NewImage']
    notif_type = record['notification_type']['S']
    trigger_datetime = record['trigger_datetime']['S']
    message = record['message']['S']
    print(f"Notif: {notif_type}, trigger datetime: {trigger_datetime}, message: {message}")

    d = datetime.datetime.now() + datetime.timedelta(minutes=5)
    event_schedule = f"cron({d.minute} {d.hour} {d.day} {d.month} ? {d.year})"
    print(f"Event schedule: {event_schedule}")

    lambda_function_name = os.environ["lambda_function_name"]
    lambda_function_arn = os.environ["lambda_function_arn"]
    try:
        event_rule_name = f"reminders-event-rule-{event_schedule}"
        response = eventbridge_client.put_rule(
            Name=event_rule_name,
            ScheduleExpression=event_schedule
        )
        event_rule_arn = response['RuleArn']
        print(f"Put rule {event_rule_name} with ARN {event_rule_arn}.")
    except ClientError:
        print(f"Couldn't put rule {event_rule_name}.")
        raise
    #
    # try:
    #     lambda_client.add_permission(
    #         FunctionName=lambda_function_name,
    #         StatementId=f'{lambda_function_name}-invoke',
    #         Action='lambda:InvokeFunction',
    #         Principal='events.amazonaws.com',
    #         SourceArn=event_rule_arn
    #     )
    #     print(f"Granted permission to let Amazon EventBridge call function {lambda_function_name}.")
    # except ClientError:
    #     print(f"Couldn't add permission to let Amazon EventBridge call function {lambda_function_name}.")
    #     raise
    #
    # try:
    #     response = eventbridge_client.put_targets(
    #         Rule=event_rule_name,
    #         Targets=[{'Id': lambda_function_name, 'Arn': lambda_function_arn}]
    #     )
    #     if response['FailedEntryCount'] > 0:
    #         print(f"Couldn't set {lambda_function_name} as the target for {event_rule_name}.")
    #     else:
    #         print(f"Set {lambda_function_name} as the target of {event_rule_name}.")
    # except ClientError:
    #     print(f"Couldn't set {lambda_function_name} as the target of {event_rule_name}.")
    #     raise

    # scheduled_event = {
    #     "username": "artyom",
    #     "city": "Almaty",
    #     "age": "31"
    # }
    # response = client.put_events(
    #     Entries=[
    #         {
    #             'Source': 'lambda-reminder-event-create',
    #             'DetailType': 'reminder-event-create',
    #             'Detail': json.dumps(scheduled_event),
    #             'EventBusName': 'reminders-events'
    #         }
    #     ]
    # )
    #
    # print(f"Response: {response}")

    return "success"
