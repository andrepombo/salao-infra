terraform {
  backend "s3" {
    bucket         = "salao-andrepombo-tf-state"
    key            = "salao-infra/prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "salao-terraform-locks"
    encrypt        = true
  }
}
