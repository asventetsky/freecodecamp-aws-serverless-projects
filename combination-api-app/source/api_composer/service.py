import requests

from api_composer.constants import URL


def get_joke():
    try:
        response = requests.get(URL, headers={'Accept': 'application/json'})
        return response.json()['joke']
    except Exception as error:
        print(f'Internal server error: ${error}')
        return None
