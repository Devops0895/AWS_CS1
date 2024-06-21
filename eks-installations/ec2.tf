# this script is for creating bastion host to connect with private instances

resource "aws_iam_instance_profile" "demo-eks-profile" {
  name = "demo_eks_profile"
  role = aws_iam_role.ec2_access_role.name
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "eks_key"
  public_key = tls_private_key.rsa.public_key_openssh

  # provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
  #   command = "echo '${tls_private_key.rsa.private_key_pem}' > ./eks_key.pem"
  # }
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "eks_key.pem"
}


resource "aws_security_group" "eks_devops_sg" {
  name        = "eks-tools-sg"
  vpc_id      = aws_vpc.my_vpc.id
  description = "this is for ec2 to ssh from putty"

  ingress {
    description = "ssh ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins ingress"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sonarqube ingress"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-tools-sg"
  }
}


resource "aws_instance" "instances" {
  ami                    = "ami-0cf2b4e024cdb6960" #"ami-0a283ac1aafe112d5" # Replace with your desired AMI ID
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.eks_devops_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.demo-eks-profile.name
  key_name               = "eks_key"

  tags = {
    Name = "eks-devops-instance"
  }


  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo sed -i "8i alias c='clear -i'" /home/ec2-user/.bashrc
sudo sed -i "8i alias c='clear -i'" /root/.bashrc

#installation of aws cli v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli/v2/2.15.42 --update
sudo echo 'export PATH="/usr/local/aws-cli/v2/2.15.42/v2/current/bin/:$PATH"' >> ~/.bashrc
sudo source .bashrc

#Installation of docker
sudo yum install docker -y

#installtion of Java & Jenkins
sudo amazon-linux-extras enable corretto8
sudo yum install java-17-amazon-corretto-devel -y

# Adding required dependencies for the jenkins package
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl start jenkins

#Adding user and providing root accesss
sudo useradd sonar
sed -i '101i sonar ALL=(ALL) NOPASSWD:ALL' /etc/sudoers

#Installing SonarQube
sudo wget -P /opt https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip
unzip	 /opt/sonarqube-9.9.4.87374.zip -d /opt
mv /opt/sonarqube-9.9.4.87374 /opt/sonarqube-9.9.4
sudo chmod +x -R /opt/sonarqube-9.9.4
sudo chown sonar:sonar -R /opt/sonarqube-9.9.4
sudo su - sonar -c "sudo /opt/sonarqube-9.9/bin/linux-x86-64/sonar.sh start"

#Installation of Trivy image scanning tool
rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.41.0/trivy_0.41.0_Linux-64bit.rpm


EOF


}

resource "null_resource" "execute_script_default_installations" {

  depends_on = [aws_key_pair.generated_key]

  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   private_key = file("./eks_key.pem")
  #   host        = aws_instance.instances.public_ip
  # }

  # provisioner "file" {
  #   source      = "userdata.sh"
  #   destination = "/home/ec2-user/userdata.sh"
  # }
}
