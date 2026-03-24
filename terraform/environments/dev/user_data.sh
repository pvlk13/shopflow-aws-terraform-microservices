#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
yum install git -y
cd /home/ec2-user
echo "Hello from Terraform" > test.txt