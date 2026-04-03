terraform {
  backend "s3" {
    bucket         = "shopflow-terraform-state-272183979798"
    key            = "shopflow/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopflow-terraform-locks"
    encrypt        = true
  }
}