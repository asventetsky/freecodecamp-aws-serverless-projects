#!/bin/bash

main() {
  cd combination-api-app/source || exit

  echo "Installing dependencies."

  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  deactivate

  echo "Dependencies have been successfully installed."
}

main "$@"; exit