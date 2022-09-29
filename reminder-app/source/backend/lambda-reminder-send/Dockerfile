FROM public.ecr.aws/lambda/python:3.9

RUN yum update -y

COPY lambda_reminder_send.py .

CMD [ "lambda_reminder_send.handler" ]