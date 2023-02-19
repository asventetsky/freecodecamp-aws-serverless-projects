#!/bin/bash

main() {
  cd source || exit

  echo "Creating directory for artifact."
  mkdir target

  echo "Creating package with dependencies."
  cd venv/lib/python3.10/site-packages/ || exit
  zip -q -r ../../../../target/lambda_combination.zip .
  cd ../../../../

  echo "Adding source code to the package."
  cd api_composer || exit
  zip -q -g ../target/lambda_artifact.zip composer.py service.py constants.py
}

main "$@"; exit
