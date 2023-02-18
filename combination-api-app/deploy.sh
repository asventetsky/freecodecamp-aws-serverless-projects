#!/bin/bash

main() {
  cd source || exit

  # Build
  echo "Building the project."
  mkdir target

  # install dependencies
  #  python3 -m venv venv
  #  source venv/bin/activate
  #  pip install -r requirements.txt
  #  deactivate

  cd venv/lib/python3.10/site-packages/ || exit
  zip -q -r ../../../../target/lambda_artifact.zip .
  cd ../../../../
  # add function code to the root of the deployment package

  cd api_composer || exit
  zip -q -g ../target/lambda_artifact.zip composer.py service.py constants.py
  cd ..

  # Test
  echo "Running tests."
  python3 -m unittest tests.test_api_composer
}

main "$@"; exit
