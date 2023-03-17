#!/bin/bash

main() {
  APP=$1
  LAMBDA_SOURCE_DIR=$2
  FILES_FOLDERS_TO_ADD=$3
  LAMBDA_ARTIFACT_NAME=$4

  echo "Variables: APP=$APP, LAMBDA_SOURCE_DIR=$LAMBDA_SOURCE_DIR, FILES_FOLDERS_TO_ADD=$FILES_FOLDERS_TO_ADD, LAMBDA_ARTIFACT_NAME=$LAMBDA_ARTIFACT_NAME."

  cd "${APP}"/source || exit

  echo "List app folder."
  ls -l

  echo "Creating a directory for artifact."
  mkdir target

  echo "Creating a package with dependencies."
  (
    cd venv/lib/python3.9/site-packages/ || exit
    zip -q -r ../../../../target/"${LAMBDA_ARTIFACT_NAME}" .
  )

  echo "Adding source code to the package."
  (
    cd $LAMBDA_SOURCE_DIR || exit
    zip -q -g ../target/"${LAMBDA_ARTIFACT_NAME}" $FILES_FOLDERS_TO_ADD
  )

  echo "Created artifact."
  ls -l target/"${LAMBDA_ARTIFACT_NAME}"
}

main "$@"; exit
