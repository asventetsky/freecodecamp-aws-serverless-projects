""" Application logic """

import uuid
import json
from dynamo_db.repository import put_record
from exception.service_exception import ServiceError
from common.response_constructor import (
    construct_success_response,
    construct_error_response,
)


def handler(event, context):
    """Contains main logic for saving reminder in database"""

    try:
        reminder = _construct_reminder(event)
        reminder["id"] = str(uuid.uuid4())
        put_record(reminder)
        return construct_success_response(reminder)
    except ServiceError as error:
        return construct_error_response(error.message)


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
