# pylint: disable=unused-argument
# pylint: disable=import-error

""" Application logic """

import json
import logging

from lambda_create_short_url.url_hash_generator import generate
from dynamo_db.repository import put_record
from exception.service_exception import ServiceError

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    """Contains main logic for creating short url and storing it in database"""

    try:
        original_url = extract_original_url(event)
        url_hash = generate(original_url)
        put_record(original_url, url_hash)
    except ServiceError as error:
        return construct_error_response(error.message)

    return construct_response(event, url_hash)


def extract_original_url(event):
    """Extracts original url from the request"""

    original_url = json.loads(event["body"]).get("originalUrl")

    if original_url is None:
        raise ServiceError("Missing `originalUrl` in a request")

    logging.info("Original url: %s", original_url)

    return original_url


def construct_error_response(error_message):
    """Constructs error response"""

    return {
        "statusCode": 500,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"error": error_message}),
    }


def construct_response(event, url_hash):
    """Constructs final response"""

    result = {"shortUrl": construct_short_url(event, url_hash)}

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(result),
    }


def construct_short_url(event, url_hash):
    """Constructs short url"""

    api_url = f"https://{event['headers']['Host']}/{event['requestContext']['stage']}"
    generated_short_url = f"{api_url}/{url_hash}"

    logging.info("Generated short url: %s", generated_short_url)

    return generated_short_url
