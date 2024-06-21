resource "aws_eks_cluster" "testekscluster" {
  name     = "${terraform.workspace}-eks-cluster"
  role_arn = aws_iam_role.Eks_Cluster_Role.arn
  tags = {
    Name = "${terraform.workspace}-eks-cluster"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
  tags_all = {
    Name = "${terraform.workspace}-eks-cluster"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
  version = "1.28"
  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.100.0.0/16"
  }

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [for s in data.aws_subnet.private_subnets : s.id]
    security_group_ids      = [data.aws_security_group.EKS-Security-Group.id]
  }
  depends_on = [aws_iam_role.Eks_Cluster_Role, aws_iam_role.Amazon_EKS_NodeRole]
}
