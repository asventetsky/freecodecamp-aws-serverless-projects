#!/bin/bash

main() {
  cd combination-api-app/source || exit

  echo "Creating a directory for artifact."
  mkdir target

  echo "Installing dependencies."
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  deactivate

  echo "Creating a package with dependencies."
  (
    cd venv/lib/python3.9/site-packages/ || exit
    zip -q -r ../../../../target/lambda_api_combiner.zip .
  )

  echo "Adding source code to the package."
  (
    cd api_composer || exit
    zip -q -g ../target/lambda_api_combiner.zip composer.py service.py constants.py
  )

  echo "Created artifact."
  unzip -l target/lambda_api_combiner.zip
}

main "$@"; exit
