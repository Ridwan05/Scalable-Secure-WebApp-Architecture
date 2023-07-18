# Configure remote backend  
terraform {
  backend "s3" {
    bucket         = "ridtf-backend"
    key            = "Dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ridtf-lock-table"
    encrypt        = true
  }
}


