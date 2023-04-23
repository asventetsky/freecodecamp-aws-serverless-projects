FROM public.ecr.aws/lambda/python:3.9

ARG lambda_source_dir

# Copy function code
COPY $lambda_source_dir ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_reminders_get/main.handler" ]