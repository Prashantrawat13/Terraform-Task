terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.30.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
  # secret_key = "YOUR_SECRET_KEY_HERE"
  # access_key = "YOUR_ACCESS_KEY_HERE"
}