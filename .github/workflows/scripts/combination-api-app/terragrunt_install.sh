#!/bin/bash

main() {
  wget -O terragrunt terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.43.2/terragrunt_linux_amd64
  chmod +x terragrunt
  sudo mv terragrunt /usr/local/bin
  terragrunt --version
}

main "$@"; exit
