terraform {
  backend "s3" {
    bucket         = "terraform-state-galen"
    key            = "dealin-front.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}