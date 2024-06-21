#!/bin/bash
sudo yum upgrade -y
sudo yum update -y
sudo yum install -y awslogs

#to modify the default location name and set it to current location
sudo sed -i "s/us-east-1/us-west-2/g" /etc/awslogs/awscli.conf

#start the aws logs agent
sudo systemctl start awslogsd

#start the service at each system boot.
sudo systemctl enable awslogsd.service

sudo yum update -y

#installtion of java

sudo wget https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz -P /opt

sudo tar xvf /root/opt/openjdk-21.0.2_linux-x64_bin.tar.gz