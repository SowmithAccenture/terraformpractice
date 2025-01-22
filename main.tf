provider "aws" {
  region = "us-east-1"
}

variable "environment" {
  default = ["dev", "stage", "prod"]
}

resource "aws_instance" "windows_vms" {
  count         = length(var.environment)
  ami           = "ami-04f77c9cd94746b09" # Replace with a valid Windows AMI
  instance_type = "t3.micro"
  key_name      = "vagrantkeypair"
  tags = {
    Name        = "windows-${var.environment[count.index]}"
    Environment = var.environment[count.index]
  }
}

# Output the public IPs of all VMs
output "windows_vm_ips" {
  value = [for instance in aws_instance.windows_vms : instance.public_ip]
}


