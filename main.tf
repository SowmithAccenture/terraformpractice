# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Common Configuration for Instances
resource "aws_instance" "vm" {
  count         = length(var.environments)
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name # Key pair for decrypting the password

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
  default     = "ami-04f77c9cd94746b09" # Ensure this is a Windows AMI
}

variable "instance_type" {
  description = "Type of instance to launch"
  default     = "t3.micro"
}

variable "environments" {
  description = "List of environments to create"
  type        = list(string)
  default     = ["dev1", "stage1", "prod1"]
}

variable "key_name" {
  description = "Key pair name for Windows login"
  default     = "terraformkeypair" # Replace with your key pair name
}
