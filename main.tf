# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Common Configuration for Windows Instances
resource "aws_instance" "windows_vm" {
  count         = length(var.environments)
  ami           = var.windows_ami_id
  instance_type = var.instance_type
  key_name      = var.windows_key_name # Key pair for Windows instances

  tags = {
    Name        = "${var.environments[count.index]}-instance"
    Environment = var.environments[count.index]
    OS          = "Windows"
  }
}

# Amazon Linux Instance Configuration
resource "aws_instance" "linux_vm" {
  ami           = var.linux_ami_id
  instance_type = var.instance_type
  key_name      = var.linux_key_name # Key pair for Linux instance

  tags = {
    Name        = "ansible-controller"
    Environment = "ansible"
    OS          = "Linux"
  }
}

# Output the Public IPs of the Instances
output "instance_public_ips" {
  value = {
    for idx, instance in aws_instance.windows_vm :
    instance.tags["Name"] => instance.public_ip
  }
}

output "linux_instance_public_ip" {
  value = {
    "ansible-controller" = aws_instance.linux_vm.public_ip
  }
}

# Output Instance IDs
output "instance_ids" {
  value = {
    for idx, instance in aws_instance.windows_vm :
    instance.tags["Name"] => instance.id
  }
}

output "linux_instance_id" {
  value = {
    "ansible-controller" = aws_instance.linux_vm.id
  }
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "windows_ami_id" {
  description = "Windows AMI ID"
  default     = "ami-04f77c9cd94746b09" # Ensure this is a Windows AMI
}

variable "linux_ami_id" {
  description = "Amazon Linux AMI ID"
  default     = "ami-0c614dee691cbbf37" # Change to the latest Amazon Linux AMI if needed
}

variable "instance_type" {
  description = "Type of instance to launch"
  default     = "t3.micro"
}

variable "environments" {
  description = "List of Windows environments to create"
  type        = list(string)
  default     = ["dev1", "stage1", "prod1"]
}

variable "windows_key_name" {
  description = "Key pair name for Windows instances"
  default     = "terraformkeypair" # Replace with your key pair name
}

variable "linux_key_name" {
  description = "Key pair name for Linux instance"
  default     = "ansiblekeypair"
}