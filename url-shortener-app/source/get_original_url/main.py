# pylint: disable=unused-argument
# pylint: disable=import-error

""" Application logic """

import json
import logging

from repository_2 import get_record

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    """ Contains main logic for getting original url """

    url_hash = extract_url_hash(event)
    original_url = get_record(url_hash)

    return construct_response(original_url)


def extract_url_hash(event):
    """ Extracts url hash from the request """

    url_hash = event['pathParameters']['hash']

    logging.info('Url hash: %s', url_hash)

    return url_hash


def construct_response(original_url):
    """ Constructs final response """

    result = {
        'originalUrl': original_url
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(result)
    }
