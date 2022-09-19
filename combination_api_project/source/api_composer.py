from webbrowser import get
import requests

def lambda_handler(event, context):

    response = requests.get("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd/kzt.json")
    
    return {
        'statusCode' : 200,
        'body': response.text
    }