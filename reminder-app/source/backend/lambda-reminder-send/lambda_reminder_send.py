import boto3

from botocore.exceptions import ClientError

ses_client = boto3.client("ses")


def handler(event, context):

    print(f"Event: {event}")

    message = "Publish next youtube video"
    destination = "artyom.sven@gmail.com"

    CHARSET = "UTF-8"
    HTML_EMAIL_CONTENT = """
        <html>
            <head></head>
            <h1 style='text-align:center'>This is the heading</h1>
            <p>{message}</p>
            </body>
        </html>
    """.format(message=message)


    try:
        response = ses_client.send_email(
            Destination={
                "ToAddresses": [
                    destination,
                ],
            },
            Message={
                "Body": {
                    "Html": {
                        "Charset": CHARSET,
                        "Data": HTML_EMAIL_CONTENT,
                    }
                },
                "Subject": {
                    "Charset": CHARSET,
                    "Data": "Amazing Email Tutorial",
                },
            },
            Source=destination,
        )
        print(f"Sent email to {destination}.")
    except ClientError as error:
        print(f"Couldn't send email to {destination}. Error: {error}")
        raise

    return "success"
