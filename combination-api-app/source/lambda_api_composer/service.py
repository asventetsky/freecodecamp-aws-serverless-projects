# pylint: disable=fixme

""" Service for sending request to external resource """

import logging
import os

import requests

logging.getLogger().setLevel(logging.INFO)


def fetch_joke():
    """Fetch and extract joke from remote resource"""
    try:
        response = _fetch_response()
        return _extract_joke(response)
    except ValueError:  # TODO: refactor to use user-defined ServiceError
        return None


def _fetch_response():
    """Fetch joke from remote resource"""
    config = _fetch_config()
    try:
        response = requests.get(
            config["URL"],
            headers={"Accept": "application/json"},
            timeout=config["TIMEOUT"],
        )
        _handle_response(response)
        return response
    except Exception as error:
        logging.error("Error occurred while sending request: %s", error)
        raise ValueError() from error


def _handle_response(response):
    """Handle response from remote resource"""
    if response.status_code != 200:
        logging.error("Non 200 status received: %s", response.status_code)
        raise ValueError()


def _fetch_config():
    """Fetch config"""
    config = {}
    try:
        config["URL"] = os.environ["JOKES_URL"]
        config["TIMEOUT"] = int(os.environ["JOKES_TIMEOUT"])
        return config
    except Exception as error:
        logging.error("Error occurred while fetching environment variables: %s", error)
        raise ValueError() from error


def _extract_joke(response):
    """Extract joke from response"""
    try:
        json_response = response.json()
        print(json_response)
    except requests.exceptions.JSONDecodeError as error:
        logging.error("Error on extracting the joke: %s", error)
        raise ValueError() from error

    if not isinstance(json_response, dict):
        logging.error(
            'Error on extracting the field "joke". Original response: %s', json_response
        )
        raise ValueError()
    return json_response["joke"]
