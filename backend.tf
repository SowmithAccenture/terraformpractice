terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-425"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}