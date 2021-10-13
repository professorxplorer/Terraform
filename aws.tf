provider "aws"{
  # access_key = "AKIA45MHVIDN2GNQ2MMV"
  # secret_key = "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"
  region     = "us-east-1"
}
terraform {
  backend "s3" {
    encrypt = true    
    bucket = "s3professorxplorer"
    dynamodb_table = "Terraform_Table"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}