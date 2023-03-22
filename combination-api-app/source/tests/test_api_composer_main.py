# pylint: disable=import-error

""" Test module """

import unittest
from unittest.mock import patch
from api_composer.main import lambda_handler


class TestApiComposerMain(unittest.TestCase):
    """Represent unit tests for main module"""

    @patch("api_composer.service")
    def test_lambda_handler(self, mock_service):
        """Unit test for lambda handler function"""

        mock_service.fetch_joke.return_value = (
            "Why do wizards clean their teeth three times a day?"
        )

        actual_response = lambda_handler({}, {})

        expected_response = {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": '{"joke1": "Why do wizards clean their teeth three times a day?'
            ' To prevent bat breath!",'
            ' "joke2": "Why do wizards clean their teeth three times a day?'
            ' To prevent bat breath!"}',
        }

        self.assertEqual(actual_response, expected_response)


if __name__ == "__main__":
    unittest.main()
