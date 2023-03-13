# pylint: disable=wrong-import-position)

""" Test module """

import sys

sys.path.append('get_original_url')

import unittest
from unittest.mock import patch
from get_original_url import main


class TestGetOriginalUrl(unittest.TestCase):
    """ Represent unit tests for getting original url """

    @patch('get_original_url.main.get_record')
    def test_lambda_handler(self, mock_get_record):
        """ Unit test for lambda handler function """

        mock_get_record.return_value = "https://url"

        event = {
            'pathParameters': {
                'hash': '123456'
            }
        }
        actual_response = main.lambda_handler(event, {})

        expected_response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': '{"originalUrl": "https://url"}'
        }

        self.assertEqual(actual_response, expected_response)


if __name__ == '__main__':
    unittest.main()
