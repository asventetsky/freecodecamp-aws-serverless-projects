#!/bin/bash

LAMBDAS_ARRAY=($(cat lambda_modules.txt))
for i in "${LAMBDAS_ARRAY[@]}"
do
  LAMBDA_ARRAY=($(echo $i | tr "=" "\n"))
  LAMBDA_NAME=${LAMBDA_ARRAY[0]}
  LAMBDA_ARTIFACT_NAME="$LAMBDA_NAME-1.zip"
  echo "LAMBDA_NAME=$LAMBDA_NAME"
  echo "LAMBDA_ARTIFACT_NAME=$LAMBDA_ARTIFACT_NAME"
done