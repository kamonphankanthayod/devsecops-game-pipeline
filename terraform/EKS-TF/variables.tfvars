# Modified by Kamonphan Kanthayod, 2026
# Based on Jenkins-Server-TF from https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-DevSecOps-Tetris-Project

vpc-name            = "Jenkins-vpc"
igw-name            = "Jenkins-igw"
subnet-name         = "Jenkins-subnet"
subnet-name2        = "Jenkins-subnet2"
security-group-name = "Jenkins-sg"
rt-name2            = "Jenkins-route-table2"
iam-role-eks        = "LabRole"
iam-role-node       = "LabRole"
iam-policy-eks      = "LabRole"
iam-policy-node     = "LabRole"
cluster-name        = "Tetris-EKS-Cluster"
eksnode-group-name  = "Tetris-Node-Group"