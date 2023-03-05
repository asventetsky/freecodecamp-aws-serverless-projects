# pylint: disable=unused-argument
# pylint: disable=import-error

""" Application logic """

import json
import logging

from service import fetch_joke

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    """ Contains major logic for combining requests from multiple resources """

    joke1 = fetch_joke()
    joke2 = fetch_joke()
    return construct_response(joke1, joke2)


def construct_response(joke1, joke2):
    """ Constructs final response """

    response = {
        'headers': {
            'Content-Type': 'application/json'
        }
    }

    if joke1 and joke2:
        response['statusCode'] = 200
        response['body'] = json.dumps({
            'joke1': joke1,
            'joke2': joke2
        })
    else:
        response['statusCode'] = 500
        response['body'] = json.dumps({
            'error': 'Internal server error'
        })

    logging.info('Response: %s', response)

    return response
