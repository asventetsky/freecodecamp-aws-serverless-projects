# pylint: disable=import-error

""" Test module """

import json
import unittest
from unittest.mock import patch

with patch.dict("os.environ", {"TABLE_NAME": "reminders", "REGION": "region"}):
    from lambda_reminder_create.main import handler


class TestLambdaReminderCreate(unittest.TestCase):
    """Represent unit tests for creating reminder"""

    @patch("lambda_reminder_create.main.put_record")
    def test_handler_success(self, mock_put_record):
        """Unit test for lambda handler function"""

        mock_put_record.return_value = None

        event = {
            "body": '{"userId": "test@email.com", "triggerDatetime": "24-06-1991T22:00", "notificationType": '
            '"email", "message": "Message"}',
            "requestContext": {"stage": "test"},
        }
        actual_response = handler(event, {})

        self.assertEqual(actual_response["statusCode"], 200)
        self.assertEqual(
            actual_response["headers"],
            {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
        )
        actual_body = json.loads(actual_response["body"])
        self.assertEqual(actual_body["user_id"], "test@email.com")
        self.assertEqual(actual_body["trigger_datetime"], "24-06-1991T22:00")
        self.assertEqual(actual_body["notification_type"], "email")
        self.assertEqual(actual_body["message"], "Message")
        self.assertIsNotNone(actual_body["id"])

    def test_handler_invalid_body_in_request(self):
        """Unit test for lambda handler function"""

        event = {
            "body": "hello",
            "requestContext": {"stage": "test"},
        }
        actual_response = handler(event, {})

        self.assertEqual(actual_response["statusCode"], 500)
        self.assertEqual(
            actual_response["headers"],
            {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
        )
        actual_body = json.loads(actual_response["body"])
        self.assertEqual(
            actual_body["error"],
            "Unable to parse body: Expecting value: line 1 column 1 (char 0)",
        )

    def test_handler_missing_user_id_in_request(self):
        """Unit test for lambda handler function"""

        event = {
            "body": '{"triggerDatetime": "24-06-1991T22:00", "notificationType": '
            '"email", "message": "Message"}',
            "requestContext": {"stage": "test"},
        }
        actual_response = handler(event, {})

        self.assertEqual(actual_response["statusCode"], 500)
        self.assertEqual(
            actual_response["headers"],
            {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
        )
        actual_body = json.loads(actual_response["body"])
        self.assertEqual(
            actual_body["error"],
            "Unable to extract required fields from the request: 'userId'",
        )


if __name__ == "__main__":
    unittest.main()
