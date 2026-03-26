# Modified by Kamonphan Kanthayod, 2026
# Based on Jenkins-Server-TF from https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-DevSecOps-Tetris-Project

terraform {
  backend "s3" {
    bucket       = "dev-tf-bucket-0116"
    region       = "us-east-1"
    key          = "End-to-End-Kubernetes-DevSecOps-Tetris-Project/EKS-TF/terraform.tfstate"
    dynamodb_table = "Lock-Files"
    use_lockfile = true
    encrypt      = true
  }
  required_version = ">=1.14.0"
  required_providers {
    aws = {
      version = ">= 5.49.0"
      source  = "hashicorp/aws"
    }
  }
}