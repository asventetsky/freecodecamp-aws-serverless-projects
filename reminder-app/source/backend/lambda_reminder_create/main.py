""" Application logic """

import uuid
import json
from dynamo_db.repository import put_record
from exception.service_exception import ServiceError


def handler(event, context):
    """Contains main logic for saving reminder in database"""

    try:
        reminder = _construct_reminder(event)
        reminder["id"] = str(uuid.uuid4())
        put_record(reminder)
        return _construct_response(reminder)
    except ServiceError as error:
        return _construct_error_response(error.message)


def _construct_reminder(event):
    """Constructs reminder from event"""

    body = _parse_body(event["body"])

    try:
        return {
            "user_id": body["userId"],
            "trigger_datetime": body["triggerDatetime"],
            "notification_type": body["notificationType"],
            "message": body["message"],
        }
    except Exception as error:
        raise ServiceError(
            f"Unable to extract required fields from the request: {error}",
        )


def _parse_body(string_body):
    try:
        return json.loads(string_body)
    except ValueError as error:
        raise ServiceError(
            f"Unable to parse body: {error}",
        )


def _construct_error_response(error_message):
    """Constructs error response"""

    return {
        "statusCode": 500,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
        },
        "body": json.dumps({"error": error_message}),
    }


def _construct_response(reminder):
    """Constructs final response"""

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
        },
        "body": json.dumps(reminder),
    }
