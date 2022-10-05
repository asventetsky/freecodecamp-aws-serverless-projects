import boto3

from botocore.exceptions import ClientError

ses_client = boto3.client("ses")
sns_client = boto3.client("sns")


def handler(event, context):
    notification_type = event['notification_type']
    if notification_type == "email":
        send_email(event)
    elif notification_type == "sms":
        send_sms(event)
    else:
        print(f"Unknown notification_type={notification_type}")

    return "success"


def send_email(event):
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


def send_sms(event):
    destination = event["destination"]
    message = event["message"]

    try:
        sns_client.publish(
            PhoneNumber=destination,
            Message=message
        )
        print(f"Sent sms to {destination}.")
    except ClientError as error:
        print(f"Couldn't send sms to {destination}. Error: {error}")
        raise

    return "success"
