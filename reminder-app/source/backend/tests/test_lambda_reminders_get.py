# pylint: disable=import-error

""" Test module """

import json
import unittest
from unittest.mock import patch

with patch.dict("os.environ", {"TABLE_NAME": "reminders", "REGION": "region"}):
    from lambda_reminders_get.main import handler


class TestLambdaRemindersGet(unittest.TestCase):
    """Represent unit tests for getting reminders"""

    @patch("lambda_reminders_get.main.get_records_by_user_id")
    def test_handler_success(self, mock_get_records_by_user_id):
        """Unit test for lambda handler function"""

        mock_get_records_by_user_id.return_value = [
            {
                "id": "1",
                "user_id": "88888888",
                "trigger_datetime": "2020-12-24T20:44",
                "notification_type": "email",
                "message": "Do not forget!",
            },
            {
                "id": "2",
                "user_id": "88888888",
                "trigger_datetime": "2020-12-31T22:00",
                "notification_type": "email",
                "message": "New Year",
            },
        ]

        event = {"queryStringParameters": {"userId": "88888888"}}
        actual_response = handler(event, {})

        expected_response = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": '[{"id": "1", "user_id": "88888888", "trigger_datetime": "2020-12-24T20:44", '
            '"notification_type": "email", "message": "Do not forget!"}, {"id": "2", "user_id": "88888888", '
            '"trigger_datetime": "2020-12-31T22:00", "notification_type": "email", "message": "New Year"}]',
        }

        self.assertEqual(actual_response, expected_response)

    def test_handler_missing_query_string_parameters_in_request(self):
        """Unit test for lambda handler function"""

        event = {}
        actual_response = handler(event, {})

        expected_response = {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": '{"error": "Unable to extract required fields from the request: \'queryStringParameters\'"}',
        }

        self.assertEqual(actual_response, expected_response)

    def test_handler_missing_user_id_in_request(self):
        """Unit test for lambda handler function"""

        event = {"queryStringParameters": {"customField": "value"}}
        actual_response = handler(event, {})

        expected_response = {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": '{"error": "Unable to extract required fields from the request: \'userId\'"}',
        }

        self.assertEqual(actual_response, expected_response)


if __name__ == "__main__":
    unittest.main()
