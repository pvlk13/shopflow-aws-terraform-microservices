aws_region          = "us-east-1"
project_name        = "shopflow"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnets  = ["10.0.21.0/24", "10.0.22.0/24"]
availability_zones  = ["us-east-1a", "us-east-1b"]
allowed_ssh_cidrs = ["62.45.86.198/32"]
ami_id        = "ami-02dfbd4ff395f2a1b" # Amazon Linux 2 (check region!)
instance_type = "t3.micro"
key_name      = "shopflow-key" # Make sure to create this key pair in AWS and update the name here
desired_capacity = 2
min_size         = 2
max_size         = 2

