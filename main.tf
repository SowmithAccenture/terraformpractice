# Define AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create S3 Bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket"  # Choose a globally unique name for your bucket
}

# Block public access for the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_block" {
  bucket = aws_s3_bucket.terraform_state.bucket

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# Define DynamoDB Table for State Locking (optional but recommended for concurrency control)
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Configure the backend to use the S3 bucket and DynamoDB table
terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_lock.name
  }
}

# Common Configuration for Instances
resource "aws_instance" "vm" {
  count         = length(var.environments)
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.environments[count.index]}-instance"
    Environment = var.environments[count.index]
  }
}

# Output the Public IPs of the Instances
output "instance_public_ips" {
  value = aws_instance.vm.*.public_ip
}

output "instance_ids" {
  value = aws_instance.vm.*.id
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-04f77c9cd94746b09" # Replace with your AMI
}

variable "instance_type" {
  description = "Type of instance to launch"
  default     = "t3.micro"
}

variable "environments" {
  description = "List of environments to create (dev, stage, prod)"
  type        = list(string)
  default     = ["dev1", "stage1", "prod1"]
}
