# Modified by Kamonphan Kanthayod, 2026
# Based on Jenkins-Server-TF from https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-DevSecOps-Tetris-Project

terraform {
  backend "s3" {
    bucket       = "dev-tf-bucket-0116-v2"
    region       = "us-east-1"
    key          = "End-to-End-Kubernetes-DevSecOps-Tetris-Project/Jenkins-Server/terraform.tfstate"
    dynamodb_table = "Lock-Files"
    encrypt      = true
    use_lockfile = true
  }
  required_version = ">=1.13.3"
  required_providers {
    aws = {
      version = ">= 6.23.0"
      source  = "hashicorp/aws"
    }
  }
}