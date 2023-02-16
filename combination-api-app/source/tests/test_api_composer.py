import unittest
from unittest.mock import MagicMock, patch
from api_composer import composer


class TestApiComposer(unittest.TestCase):

    @patch('api_composer.service.requests')
    def test_lambda_handler(self, mock_requests):
        # mock the response
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'joke': 'Why do wizards clean their teeth three times a day? To prevent bat breath!'
        }

        # specify the return value of the get() method
        mock_requests.get.return_value = mock_response

        actual_response = composer.lambda_handler({}, {})

        expected_response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': '{"joke1": "Why do wizards clean their teeth three times a day? To prevent bat breath!", "joke2": "Why do wizards clean their teeth three times a day? To prevent bat breath!"}'
        }

        self.assertEqual(actual_response,expected_response)


if __name__ == '__main__':
    unittest.main()
