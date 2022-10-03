import boto3

from botocore.exceptions import ClientError

ses_client = boto3.client("ses")


def handler(event, context):

    print(f"Event: {event}")

    # hardcoded value of source address
    source = "paul.grubov@gmail.com"
    destination = event["destination"]
    message = event["message"]

    CHARSET = "UTF-8"
    HTML_EMAIL_CONTENT = """
        <html>
            <head></head>
            <h1 style='text-align:center'>Reminder App: don't forget about it!</h1>
            <p>{message}</p>
            </body>
        </html>
    """.format(message=message)


    try:
        ses_client.send_email(
            Source=source,
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
                    "Data": "Reminder App"
                },
            }
        )
        print(f"Sent email to {destination}.")
    except ClientError as error:
        print(f"Couldn't send email to {destination}. Error: {error}")
        raise

    return "success"
