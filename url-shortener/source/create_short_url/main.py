import json
import logging

from repository import put_record
from url_hash_generator import generate

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    original_url = extract_original_url(event)
    url_hash = generate(original_url)
    put_record(original_url, url_hash)

    result = {
        'shortUrl': construct_short_url(event, url_hash)
    }

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(result)
    }


def extract_original_url(event):
    original_url = json.loads(event['body'])['originalUrl']

    logging.info('Original url: %s', original_url)

    return original_url


def construct_short_url(event, url_hash):
    api_url = f"https://{event['headers']['Host']}/{event['requestContext']['stage']}"
    generated_short_url = f"{api_url}/{url_hash}"

    logging.info('Generated short url: %s', generated_short_url)

    return generated_short_url
