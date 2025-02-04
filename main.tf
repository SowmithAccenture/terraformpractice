# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Windows Instances Configuration
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

# Amazon Linux Ansible Controller Configuration
resource "aws_instance" "linux_vm" {
  ami           = var.linux_ami_id
  instance_type = var.instance_type
  key_name      = var.linux_key_name # Key pair for Linux instance

  tags = {
    Name        = "ansible-controller"
    Environment = "ansible"
    OS          = "Linux"
  }

  # Install Ansible automatically on startup
  user_data = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras enable ansible2
  sudo yum install -y ansible
  ansible --version
  EOF
}

# Output the Public IPs of the Windows Instances
output "windows_instance_public_ips" {
  value = {
    for instance in aws_instance.windows_vm :
    instance.tags["Name"] => instance.public_ip
  }
}

# Output the Public IP of the Linux Ansible Controller
output "linux_instance_public_ip" {
  value = {
    "ansible-controller" = aws_instance.linux_vm.public_ip
  }
}

# Output Instance IDs for Windows VMs
output "windows_instance_ids" {
  value = {
    for instance in aws_instance.windows_vm :
    instance.tags["Name"] => instance.id
  }
}

# Output Instance ID for the Linux Ansible Controller
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
  default     = "ami-0f214d1b3d031dc53" # Update if needed
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
  default     = "terraformkeypair"
}

variable "linux_key_name" {
  description = "Key pair name for Linux instance"
  default     = "ansiblekeypair"
}
