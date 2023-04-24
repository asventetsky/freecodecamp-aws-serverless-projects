#!/bin/bash

main() {
  echo "Creating a directory for artifact."
  mkdir -p target

  echo "Installing dependencies."
  if [ ! -d "venv" ]
  then
    python3 -m venv venv
  fi
  source venv/bin/activate
  pip install -r requirements.txt
  deactivate

  LAMBDAS_ARRAY=$(echo $(cat lambda_modules.txt))

  LAMBDAS_COMMON_VARS=''
  for i in ${LAMBDAS_ARRAY[@]}
  do
    LAMBDA_ARRAY=($(echo "$i" | tr "=" " "))

    LAMBDA_NAME=${LAMBDA_ARRAY[0]}
    echo "LAMBDA_NAME=$LAMBDA_NAME"
    LAMBDA_ARTIFACT_NAME="$LAMBDA_NAME-local.zip"
    echo "LAMBDA_ARTIFACT_NAME=$LAMBDA_ARTIFACT_NAME"

    LAMBDAS_COMMON_VARS+="${LAMBDA_NAME}_artifact_name: \"$LAMBDA_ARTIFACT_NAME\";"

    FILES_FOLDERS_TO_ADD=($(echo ${LAMBDA_ARRAY[1]} | tr ',' ' '))

    echo "Creating a package with dependencies."
    (
      cd venv/lib/python3.10/site-packages/ || exit
      zip -q -r ../../../../target/"${LAMBDA_ARTIFACT_NAME}" .
    )

    echo "Adding source code to the package."
    zip -q -g -r target/${LAMBDA_ARTIFACT_NAME} "$FILES_FOLDERS_TO_ADD"

    echo "Created artifact."
    ls -l target/"${LAMBDA_ARTIFACT_NAME}"
  done

  echo "LAMBDAS_COMMON_VARS=$LAMBDAS_COMMON_VARS"

  LAMBDAS_COMMON_VARS_ARRAY=$((echo $LAMBDAS_COMMON_VARS) | tr ";" "\n")

  for i in "${LAMBDAS_COMMON_VARS_ARRAY[@]}"
  do
    (echo ""; echo "$i") >> ../infrastructure/environments/common_vars.yaml
  done
}

main "$@"; exit