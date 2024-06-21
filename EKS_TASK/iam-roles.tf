resource "aws_iam_role" "Eks_Cluster_Role" {
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  description           = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
  force_detach_policies = false
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
  max_session_duration  = 3600
  name                  = "EksClusterServiceRole"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
}

resource "aws_iam_role" "Amazon_EKS_NodeRole" {
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  description           = "Allows EC2 instances to call AWS services on your behalf."
  force_detach_policies = false
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  max_session_duration  = 3600
  name                  = "AmazonEKSNodeRole"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
}


resource "aws_iam_policy" "eks_asg_policy" {
  name = "eks-asg-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource" : "*"
      }
    ]
  })
}




resource "aws_iam_role" "Amazon_EC2_EKS" {
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  description           = "Allows EC2 instances to call AWS services on your behalf."
  force_detach_policies = false
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  max_session_duration  = 3600
  name                  = "AmazonEC2EKS"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
}

resource "aws_iam_instance_profile" "EKS-EC2" {
  name = "EKS-EC2"
  role = aws_iam_role.Amazon_EC2_EKS.id
}
