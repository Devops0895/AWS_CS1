resource "aws_launch_template" "example" {
  name_prefix = "example-lt"

  key_name = aws_key_pair.Node_key_pair.key_name

  vpc_security_group_ids = [data.aws_security_group.EKS-Security-Group.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      #kms_key_id            = data.aws_kms_key.my_key.arn # Reference to the KMS key ARN
    }
  }

  block_device_mappings {
    device_name = "/dev/sdh"
    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      #kms_key_id            = data.aws_kms_key.my_key.arn # Reference to the KMS key ARN
    }
  }
  tags = {
    Name = "example-lt"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
  depends_on = [aws_eks_cluster.testekscluster]
}
