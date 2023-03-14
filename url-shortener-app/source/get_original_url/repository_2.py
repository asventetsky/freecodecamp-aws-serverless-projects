""" Access to the database """

import logging

import botocore
import boto3

client = boto3.client('dynamodb', region_name='eu-central-1')
TABLE_NAME = "short-urls"

logging.getLogger().setLevel(logging.INFO)


def get_record(url_hash):
    """ Get record from DynamoDb """

    try:
        response = client.get_item(
            TableName=TABLE_NAME,
            Key={
                'hash': {
                    'S': url_hash
                }
            },
            ProjectionExpression='original_url'
        )

        original_url = response['Item']['originalUrl']['S']
        logging.info('Original url: %s', original_url)

        return original_url

    except botocore.exceptions.ClientError as error:
        logging.error('Error occurred while getting original url: %s', error)
        raise
