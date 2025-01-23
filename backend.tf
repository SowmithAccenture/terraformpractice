terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-425"  # Your S3 bucket name
    key            = "terraform.tfstate"              # Path in the S3 bucket where the state file is stored
    region         = "us-east-1"                       # Your AWS region
    encrypt        = true                              # Enable encryption for the state file
  }
}
