data "aws_vpc" "main_vpc" {

  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Subnet-Type"
    values = ["${terraform.workspace}-private"]
  }
}

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_security_group" "EKS-Security-Group" {
  name = "${terraform.workspace}-eks-cluster-sg"
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Subnet-Type"
    values = ["public"]
  }
}

data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["public_subnet_1"]
  }
}

data "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}
/*
data "aws_kms_key" "my_key" {
  key_id = "arn:aws:kms:region:account-id:key/key-id" #enter your existing kms key id
}
*/

data "aws_autoscaling_groups" "eks_asg" {
  filter {
    name   = "tag:kubernetes.io/cluster/${terraform.workspace}-eks-cluster"
    values = ["owned"]
  }
  depends_on = [aws_eks_node_group.testeksclusternode]
}

