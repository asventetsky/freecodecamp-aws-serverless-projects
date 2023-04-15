""" Access to the database """

import logging
import os

import botocore
import boto3

client = boto3.client("dynamodb", region_name=os.environ["REGION"])
TABLE_NAME = os.environ["TABLE_NAME"]

logging.getLogger().setLevel(logging.INFO)


def put_record(reminder):
    """Puts record into DynamoDb"""

    try:
        client.put_item(
            TableName=TABLE_NAME,
            Item={
                "id": {"S": reminder["id"]},
                "user_id": {"S": reminder["user_id"]},
                "trigger_datetime": {"S": reminder["trigger_datetime"]},
                "notification_type": {"S": reminder["notification_type"]},
                "message": {"S": reminder["message"]},
            },
        )
        return reminder
    except botocore.exceptions.ClientError as error:
        logging.error("Error occurred while saving short url: %s", error)
        raise
