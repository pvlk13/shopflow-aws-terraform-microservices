resource "random_password" "db_password" {
  length  = 20
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.project_name}-postgres-db"
  allocated_storage       = 20
  max_allocated_storage   = 100
  engine                  = "postgres"
  engine_version          = "16.12"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db_password.result
  port                    = 5432
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.project_name}-postgres-db"
  }
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/shopflow/db/host"
  type  = "String"
  value = aws_db_instance.this.address
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/shopflow/db/port"
  type  = "String"
  value = "5432"
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/shopflow/db/name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/shopflow/db/user"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/shopflow/db/password"
  type  = "SecureString"
  value = random_password.db_password.result
}