resource "aws_eks_node_group" "testeksclusternode" {
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t2.medium"]
  cluster_name    = aws_eks_cluster.testekscluster.name
  node_group_name = "${terraform.workspace}-eks-nodegroup-1"
  node_role_arn   = aws_iam_role.Amazon_EKS_NodeRole.arn
  subnet_ids      = [for s in data.aws_subnet.private_subnets : s.id]
  tags = {
    Name = "test-eks-nodegroup-1"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
  tags_all = {
    Name = "test-eks-nodegroup-1"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }

  #version = "1.28"
  scaling_config {
    desired_size = 3
    max_size     = 20
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  depends_on = [aws_eks_cluster.testekscluster]
}
