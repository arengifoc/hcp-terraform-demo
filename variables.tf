# Variables for HTML Website Demo
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region name."
  }
}

variable "instance_type" {
  description = "EC2 instance type for web server"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium",
      "t2.micro", "t2.small", "t2.medium"
    ], var.instance_type)
    error_message = "Instance type must be a valid AWS instance type from the allowed list."
  }
}

variable "project_name" {
  description = "Name of the project used for resource naming and tagging"
  type        = string
  default     = "html-demo"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the website"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "ID of the existing VPC to use for resources"
  type        = string
  
  validation {
    condition = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid VPC identifier starting with 'vpc-'."
  }
}

variable "public_subnet_id" {
  description = "ID of the existing public subnet where EC2 instance will be placed"
  type        = string
  
  validation {
    condition = can(regex("^subnet-[a-z0-9]+$", var.public_subnet_id))
    error_message = "Subnet ID must be a valid subnet identifier starting with 'subnet-'."
  }
}

variable "key_pair_name" {
  description = "Name of the AWS key pair to use for EC2 instance SSH access"
  type        = string
  default     = "kp-arengifo"
  
  validation {
    condition = length(var.key_pair_name) > 0
    error_message = "Key pair name cannot be empty."
  }
}