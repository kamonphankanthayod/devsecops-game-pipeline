# Modified by Kamonphan Kanthayod, 2026
# Based on Jenkins-Server-TF from https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-DevSecOps-Tetris-Project

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.eksnode-group-name
  node_role_arn   = "arn:aws:iam::508252589627:role/LabRole"
  subnet_ids      = [data.aws_subnet.subnet.id, aws_subnet.public-subnet2.id]


  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["c7i-flex.large"]
  disk_size      = 20
}