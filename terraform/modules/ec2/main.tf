resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.app_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Install Docker
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user

              # Install Git
              yum install git -y

              # Clone your repo
              git clone https://github.com/pvlk13/shopflow-aws-terraform-microservices.git
              cd shopflow

              # Start services
              docker compose up -d
              EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}