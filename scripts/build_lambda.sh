#!/bin/bash

main() {
  LAMBDA_SOURCE_DIR=$1
  LAMBDA_MODULES="$LAMBDA_SOURCE_DIR $2 __init__.py"
  echo "LAMBDA_MODULES=$LAMBDA_MODULES"
  LAMBDA_ARTIFACT_NAME="${LAMBDA_SOURCE_DIR}_artifact.zip"
  echo "LAMBDA_ARTIFACT_NAME=$LAMBDA_ARTIFACT_NAME"

  echo "Creating a directory for artifact."
  mkdir -p target

  echo "Installing dependencies."
  if [ -d "venv" ]
  then
    python3 -m venv venv
  fi
  source venv/bin/activate
  pip install -r requirements.txt
  deactivate

  echo "Creating a package with dependencies."
  (
    cd venv/lib/python3.10/site-packages/ || exit
    zip -q -r ../../../../target/$LAMBDA_ARTIFACT_NAME .
  )

  echo "Adding source code to the package."
  zip -q -g -r target/$LAMBDA_ARTIFACT_NAME $LAMBDA_MODULES
}

main "$@"; exit
