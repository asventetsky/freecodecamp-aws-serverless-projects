import boto3
import random
import string

client = boto3.client('dynamodb')

def lambda_handler(event, context):

    hash = ''.join(random.choices(string.ascii_lowercase, k=8))

    data = client.put_item(
        TableName='short-urls',
        Item={
            'hash': {
                'S': hash
            },
            'originalUrl': {
                'S': 'http://localhost:4000'
            }
        }
    )

    print(data)

    return data
