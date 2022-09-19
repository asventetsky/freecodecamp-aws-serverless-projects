terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.30.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.1.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
