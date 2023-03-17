#!/bin/bash

main() {
  APP=$1
  LAMBDA_SOURCE_DIR=$2
  FILES_AND_FOLDER_TO_ADD=$3
  LAMBDA_ARTIFACT_NAME=$4

  cd "${APP}"/source || exit

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
    zip -q -g ../target/"${LAMBDA_ARTIFACT_NAME}" $FILES_AND_FOLDER_TO_ADD
  )

  echo "Created artifact."
  ls -l target/"${LAMBDA_ARTIFACT_NAME}"
}

main "$@"; exit
