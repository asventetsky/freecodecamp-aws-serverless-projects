# pylint: disable=unused-argument

""" Application logic """

import json
import logging
import requests

logging.getLogger().setLevel(logging.INFO)

URL = 'https://icanhazdadjoke.com/'
TIMEOUT = 5


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


def fetch_joke():
    """ Get joke from remote resource """
    response = fetch_response()
    if response.status_code != 200:
        logging.error('Non 200 status received: %s', response)
        return None

    return extract_joke(response)


def fetch_response():
    """ Get joke from remote resource """

    try:
        return requests.get(URL, headers={'Accept': 'application/json'}, timeout=TIMEOUT)
    except requests.exceptions.RequestException as error:
        logging.error('Error occurred while sending request: %s', error)
        return None


def extract_joke(response):
    """ Extract joke from response """

    try:
        return response.json()['joke']
    except requests.exceptions.JSONDecodeError as error:
        logging.error('Error on extracting the joke: %s', error)
        return None
