resource "aws_instance" "my_ec2" {
  instance_type               = "t2.micro"
  ami                         = "ami-0395649fbe870727e"
  subnet_id                   = data.aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [data.aws_security_group.EKS-Security-Group.id]
  key_name                    = aws_key_pair.Node_key_pair.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.EKS-EC2.name
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.keypair.private_key_pem
    host        = aws_instance.my_ec2.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/${terraform.workspace}-Node-key.pem"
    destination = "/home/ec2-user/.ssh/${terraform.workspace}-Node-key.pem"
  }


  provisioner "file" {
    source      = "${path.module}/role.yaml"
    destination = "/home/ec2-user/role.yaml"
  }

  user_data = <<EOF
#!/bin/bash
set -x
cat <<EOFR | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOFR
sudo yum install -y kubectl
sudo aws eks --region us-west-2 update-kubeconfig --name test-eks-cluster
sudo chmod 700 /home/ec2-user/.ssh/Node-key.pem
sudo cp ${path.module}/configHost ~/.ssh/
EOF
  tags = {
    Name = "EKS-EC2"
    Date = local.current_date
    Env  = "${terraform.workspace}"
  }
  depends_on = [aws_eks_cluster.testekscluster, aws_eks_node_group.testeksclusternode]
}
