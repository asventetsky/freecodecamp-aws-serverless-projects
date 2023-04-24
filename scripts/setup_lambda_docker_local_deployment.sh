#!/bin/bash

build_and_push_images() {
  AWS_REGION=$1
  REPOSITORY_URI=$2
  TERRAGRUNT_ENV_VARS_PATH=$3
  ECR_ACCOUNT=${REPOSITORY_URI%/*}

  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_ACCOUNT || exit

  LAMBDAS_SPEC=$(cat lambdas_spec.txt)

  LAMBDAS_ENV_VARS=''
  for lambda_spec in ${LAMBDAS_SPEC[@]}
  do
    # Fetch lambda name and lambda version
    LAMBDA_SPEC=($(echo "$lambda_spec" | tr "=" " "))
    LAMBDA_NAME_AND_VERSION=($(echo "${LAMBDA_SPEC[0]}" | tr ":" " "))
    LAMBDA_NAME=${LAMBDA_NAME_AND_VERSION[0]}
    LAMBDA_VERSION="${LAMBDA_NAME_AND_VERSION[1]}-local"
    echo "LAMBDA_NAME=$LAMBDA_NAME"
    echo "LAMBDA_VERSION=$LAMBDA_VERSION"

    LAMBDAS_ENV_VARS+="${LAMBDA_NAME}_version: \"${LAMBDA_VERSION}\";"

    # Fetch required lambda modules
    LAMBDA_MODULES=$(echo "${LAMBDA_SPEC[1]}" | sed 's/,/\/ /g')
    echo "LAMBDA_MODULES=$LAMBDA_MODULES"

    ARTIFACT_DIRECTORY="temp_$LAMBDA_NAME"
    echo "ARTIFACT_DIRECTORY=$ARTIFACT_DIRECTORY"

    echo "Creating temp directory '$ARTIFACT_DIRECTORY'"
    mkdir -p $ARTIFACT_DIRECTORY

    cp -r $LAMBDA_MODULES $ARTIFACT_DIRECTORY

    docker build -t "$LAMBDA_NAME:$LAMBDA_VERSION" -f "$LAMBDA_NAME/Dockerfile" --build-arg lambda_source_dir=$ARTIFACT_DIRECTORY .
    docker tag "${LAMBDA_NAME}:${LAMBDA_VERSION}" "${REPOSITORY_URI}:${LAMBDA_NAME}_${LAMBDA_VERSION}"
    docker push "${REPOSITORY_URI}:${LAMBDA_NAME}_${LAMBDA_VERSION}"

    echo "Removing artifact directory '$ARTIFACT_DIRECTORY'"
    rm -rf $ARTIFACT_DIRECTORY
  done

  echo "LAMBDAS_ENV_VARS=$LAMBDAS_ENV_VARS"
  echo "TERRAGRUNT_ENV_VARS_PATH=$TERRAGRUNT_ENV_VARS_PATH"

  LAMBDAS_ENV_VARS_ARRAY=$((echo $LAMBDAS_ENV_VARS) | tr ";" "\n")

  for i in "${LAMBDAS_ENV_VARS_ARRAY[@]}"
  do
    (echo ""; echo "$i") >> $TERRAGRUNT_ENV_VARS_PATH
  done
}

main() {
  AWS_REGION=$1
  REPOSITORY_URI=$2
  TERRAGRUNT_ENV_VARS_PATH=$3

  build_and_push_images $AWS_REGION $REPOSITORY_URI $TERRAGRUNT_ENV_VARS_PATH
}

main "$@"; exit
