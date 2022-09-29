FROM public.ecr.aws/lambda/python:3.9

RUN yum update -y

COPY lambda_reminder_event_create.py .

CMD [ "lambda_reminder_event_create.handler" ]