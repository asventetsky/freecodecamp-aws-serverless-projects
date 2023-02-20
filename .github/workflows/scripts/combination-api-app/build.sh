#!/bin/bash

main() {
  cd combination-api-app/source || exit

  echo "Creating directory for artifact."
  mkdir target

  echo "Installing dependencies."
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  deactivate

  echo "Creating package with dependencies."
  cd venv/lib/python3.9/site-packages/ || exit
  zip -q -r ../../../../target/lambda_combination.zip .
  cd ../../../../

  echo "Adding source code to the package."
  cd api_composer || exit
  zip -q -g ../target/lambda_artifact.zip composer.py service.py constants.py
}

main "$@"; exit
