""" Access to the database """

import logging

import botocore
import boto3

client = boto3.client("dynamodb", region_name="eu-central-1")
TABLE_NAME = "short-urls"

logging.getLogger().setLevel(logging.INFO)


def put_record(original_url, url_hash):
    """Puts record into DynamoDb"""

    try:
        client.put_item(
            TableName=TABLE_NAME,
            Item={"original_url": {"S": original_url}, "url_hash": {"S": url_hash}},
        )
    except botocore.exceptions.ClientError as error:
        logging.error("Error occurred while saving short url: %s", error)
        raise


def get_record(url_hash):
    """Get record from DynamoDb"""

    try:
        response = client.get_item(
            TableName=TABLE_NAME,
            Key={"url_hash": {"S": url_hash}},
            ProjectionExpression="original_url",
        )

        original_url = response["Item"]["original_url"]["S"]
        logging.info("Original url: %s", original_url)

        return original_url

    except botocore.exceptions.ClientError as error:
        logging.error("Error occurred while getting original url: %s", error)
        raise
