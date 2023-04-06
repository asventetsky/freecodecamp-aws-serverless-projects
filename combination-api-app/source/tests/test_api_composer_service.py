# pylint: disable=import-error

""" Test module """

import os
import unittest
from unittest.mock import MagicMock, patch
from lambda_api_composer.service import fetch_joke


class TestApiComposerService(unittest.TestCase):
    """Represent unit tests for service module"""

    @patch("lambda_api_composer.service.requests")
    @patch.dict(os.environ, {"JOKES_URL": "https://url", "JOKES_TIMEOUT": "5"})
    def test_fetch_joke_success_response(self, mock_requests):
        """Unit test for fetch joke function"""

        # mock the response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "joke": "Why do wizards clean their teeth three times a day? To prevent bat breath!"
        }

        # specify the return value of the get() method
        mock_requests.get.return_value = mock_response

        actual_response = fetch_joke()

        expected_response = (
            "Why do wizards clean their teeth three times a day? To prevent bat breath!"
        )

        self.assertEqual(actual_response, expected_response)

    @patch("lambda_api_composer.service.requests")
    @patch.dict(os.environ, {"JOKES_URL": "https://url", "JOKES_TIMEOUT": "abc"})
    def test_fetch_joke_invalid_timeout_value(self, mock_requests):
        """Unit test for lambda handler function"""

        # mock the response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "joke": "Why do wizards clean their teeth three times a day? To prevent bat breath!"
        }

        # specify the return value of the get() method
        mock_requests.get.return_value = mock_response

        actual_response = fetch_joke()

        self.assertEqual(actual_response, None)

    @patch("lambda_api_composer.service.requests")
    @patch.dict(os.environ, {"JOKES_URL": "https://url", "JOKES_TIMEOUT": "5"})
    def test_fetch_joke_exception_fetching_joke(self, mock_requests):
        """Unit test for lambda handler function"""
        mock_requests.get.side_effect = MagicMock(side_effect=Exception("Test"))

        actual_response = fetch_joke()

        self.assertEqual(actual_response, None)

    @patch("lambda_api_composer.service.requests")
    @patch.dict(os.environ, {"JOKES_URL": "https://url", "JOKES_TIMEOUT": "5"})
    def test_fetch_joke_non_200_response_status_code(self, mock_requests):
        """Unit test for lambda handler function"""

        # mock the response
        mock_response = MagicMock()
        mock_response.status_code = 500
        mock_response.json.return_value = {"error": "Internal Server Error"}

        # specify the return value of the get() method
        mock_requests.get.return_value = mock_response

        actual_response = fetch_joke()

        self.assertEqual(actual_response, None)

    @patch("lambda_api_composer.service.requests")
    @patch.dict(os.environ, {"JOKES_URL": "https://url", "JOKES_TIMEOUT": "5"})
    def test_fetch_joke_invalid_json_response(self, mock_requests):
        """Unit test for lambda handler function"""

        # mock the response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = (
            "<joke>Why do wizards clean their teeth three times a day?</joke>"
        )

        # specify the return value of the get() method
        mock_requests.get.return_value = mock_response

        actual_response = fetch_joke()

        self.assertEqual(actual_response, None)


if __name__ == "__main__":
    unittest.main()
