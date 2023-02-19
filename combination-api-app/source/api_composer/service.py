# pylint: disable=no-member

""" Service for sending request to external resource """

import logging
import requests

from api_composer.constants import URL, TIMEOUT

logging.getLogger().setLevel(logging.INFO)


def fetch_joke():
    """ Get joke from remote resource """
    response = fetch_response()
    return extract_joke(response) if response.status_code != requests.codes.ok else None


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
