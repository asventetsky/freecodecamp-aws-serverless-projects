""" Access to the database """

import logging
import os

import botocore
import boto3
from exception.service_exception import ServiceError

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
        logging.error("Unable to put reminder: %s", error)
        raise ServiceError("Error on saving reminder")


def get_records_by_user_id(user_id):
    db_records = _get_records_by_id_from_db(user_id)
    return _map_records(db_records)


def _get_records_by_id_from_db(user_id):
    try:
        return client.query(
            TableName=TABLE_NAME,
            IndexName="UserIdIndex",
            KeyConditionExpression="user_id = :user_id",
            ExpressionAttributeValues={":user_id": {"S": user_id}},
        )
    except botocore.exceptions.ClientError as error:
        logging.error("Unable to get reminders by user_id `%s`: %s", user_id, error)
        raise ServiceError("Error on getting reminders by user id")


def _map_records(db_records):
    try:
        mapped_records = []
        for db_record in db_records["Items"]:
            mapped_record = {
                "id": db_record["id"]["S"],
                "user_id": db_record["user_id"]["S"],
                "trigger_datetime": db_record["trigger_datetime"]["S"],
                "notification_type": db_record["notification_type"]["S"],
                "message": db_record["message"]["S"],
            }
            mapped_records.append(mapped_record)
        return mapped_records
    except Exception as error:
        logging.error("Unable to map reminders from db: %s", error)
        raise ServiceError("Error on getting reminders by user id")
