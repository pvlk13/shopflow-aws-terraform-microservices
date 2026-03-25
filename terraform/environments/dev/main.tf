provider "aws" {
  region = var.aws_region
}

module "vpc" {
 source               = "../../modules/vpc"
 project_name         = var.project_name
 vpc_cidr             = var.vpc_cidr
 public_subnet_cidrs  = var.public_subnet_cidrs
 private_app_subnets  = var.private_app_subnets
 private_db_subnets   = var.private_db_subnets
 availability_zones   = var.availability_zones

}
module "security_groups" {
  source            = "../../modules/security-groups"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  db_sg_id              = module.security_groups.db_sg_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}
module "ec2" {
  source           = "../../modules/ec2"
  project_name     = var.project_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  public_subnet_id = module.vpc.public_subnet_ids[0]
  app_sg_id        = module.security_groups.app_sg_id
  key_name         = var.key_name
}
module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  alb_sg_id         = module.security_groups.alb_sg_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_port       = 8015
  health_check_path = "/health"
}

module "asg" {
  source                 = "../../modules/asg"
  project_name           = var.project_name
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  app_sg_id              = module.security_groups.app_sg_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  target_group_arn       = module.alb.target_group_arn
  desired_capacity       = var.desired_capacity
  min_size               = var.min_size
  max_size               = var.max_size
  user_data              = file("${path.module}/user_data.sh")
}
module "cloudwatch" {
  source       = "../../modules/cloudwatch"
  project_name = var.project_name
  asg_name     = module.asg.asg_name
}