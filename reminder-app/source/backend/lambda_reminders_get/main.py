""" Application logic """

from dynamo_db.repository import get_records_by_user_id
from exception.service_exception import ServiceError
from common.response_constructor import (
    construct_success_response,
    construct_error_response,
)


def handler(event, context):
    try:
        user_id = _get_user_id_from_query_params(event)
        records = get_records_by_user_id(user_id)
        return construct_success_response(records)
    except ServiceError as error:
        return construct_error_response(error.message)


def _get_user_id_from_query_params(event):
    try:
        query_parameters = event["queryStringParameters"]
        return query_parameters["userId"]
    except KeyError as error:
        raise ServiceError(
            f"Unable to extract required fields from the request: {error}"
        )
