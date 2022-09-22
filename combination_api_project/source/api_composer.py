import json
import requests

URL = 'https://icanhazdadjoke.com/'
headers = {'Accept': 'application/json'}

def lambda_handler(event, context):

    result = {
        "statusCode" : 200,
        "headers": {
            "Content-Type": "application/json"
        }
    }

    try:
        joke1_response = requests.get(URL, headers=headers)
        joke2_response = requests.get(URL, headers=headers)
        joke1 = joke1_response.json()['joke']
        joke2 = joke2_response.json()['joke']
    except Exception as error:
        print('Internal server error', error)
        result["statusCode"] = 500
        result["body"] = json.dumps({
            "error": "Internal server error"
        })
    else:
        result["body"] = json.dumps({
            "joke_1": joke1,
            "joke_2": joke2
        })

    print("Combined response: ", result)

    return result
