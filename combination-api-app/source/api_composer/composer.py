import json
import logging

from api_composer.service import get_joke

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    joke1 = get_joke()
    joke2 = get_joke()
    return construct_response(joke1, joke2)


def construct_response(joke1, joke2):
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

    logging.info(f"Response: {response}")

    return response
