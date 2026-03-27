# Modified by Kamonphan Kanthayod, 2026
# Based on Jenkins-Server-TF from https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-DevSecOps-Tetris-Project

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  vpc_config {
    subnet_ids         = [data.aws_subnet.subnet.id, aws_subnet.public-subnet2.id]
    security_group_ids = [data.aws_security_group.sg-default.id]
  }

  version = 1.29
}

data "aws_caller_identity" "current" {}