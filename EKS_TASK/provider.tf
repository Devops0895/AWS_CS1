terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

}

locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
}

resource "null_resource" "kubectl_setup" {
  provisioner "local-exec" {
    command = <<EOT
      sudo chmod 777 kubesetup.sh
      sudo bash ${path.module}/kubesetup.sh
    EOT
  }
  depends_on = [aws_eks_cluster.testekscluster, aws_eks_node_group.testeksclusternode]
}
