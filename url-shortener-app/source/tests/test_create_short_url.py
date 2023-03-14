# pylint: disable=wrong-import-position)

""" Test module """

import sys

sys.path.append('create_short_url')

import unittest
from unittest.mock import patch
from create_short_url import main


class TestCreateShortUrl(unittest.TestCase):
    """ Represent unit tests for creating short url """

    @patch('create_short_url.main.generate')
    @patch('create_short_url.main.put_record')
    def test_lambda_handler(self, mock_put_record, mock_generate_url_hash):
        """ Unit test for lambda handler function """

        mock_generate_url_hash.return_value = "123456"
        mock_put_record.return_value = None

        event = {
            'body': '{"originalUrl": "https://url"}',
            'headers': {
                'Host': 'domainhost'
            },
            'requestContext': {
                'stage': 'test'
            }
        }
        actual_response = main.lambda_handler(event, {})

        expected_response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': '{"shortUrl": "https://domainhost/test/123456"}'
        }

        self.assertEqual(actual_response, expected_response)


if __name__ == '__main__':
    unittest.main()
