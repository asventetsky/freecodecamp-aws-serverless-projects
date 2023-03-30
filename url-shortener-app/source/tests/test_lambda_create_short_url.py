# pylint: disable=import-error

""" Test module """

import unittest
from unittest.mock import patch
from lambda_create_short_url.main import lambda_handler


class TestLambdaCreateShortUrl(unittest.TestCase):
    """Represent unit tests for creating short url"""

    @patch("lambda_create_short_url.main.generate")
    @patch("lambda_create_short_url.main.put_record")
    def test_lambda_handler_success(self, mock_put_record, mock_generate_url_hash):
        """Unit test for lambda handler function"""

        mock_generate_url_hash.return_value = "123456"
        mock_put_record.return_value = None

        event = {
            "body": '{"originalUrl": "https://url"}',
            "headers": {"Host": "domainhost"},
            "requestContext": {"stage": "test"},
        }
        actual_response = lambda_handler(event, {})

        expected_response = {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": '{"shortUrl": "https://domainhost/test/123456"}',
        }

        self.assertEqual(actual_response, expected_response)

    def test_lambda_handler_missing_original_url_in_request(self):
        """Unit test for lambda handler function"""

        event = {
            "body": '{"field": "field_value"}',
            "headers": {"Host": "domainhost"},
            "requestContext": {"stage": "test"},
        }
        actual_response = lambda_handler(event, {})

        expected_response = {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": '{"error": "Missing `originalUrl` in a request"}',
        }

        self.assertEqual(actual_response, expected_response)


if __name__ == "__main__":
    unittest.main()
