# Variables for WordPress Demo
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
  description = "EC2 instance type for WordPress server"
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

variable "db_instance_class" {
  description = "RDS instance class for MySQL database"
  type        = string
  default     = "db.t3.micro"
  
  validation {
    condition = can(regex("^db\\.", var.db_instance_class))
    error_message = "DB instance class must be a valid RDS instance class starting with 'db.'."
  }
}

variable "project_name" {
  description = "Name of the project used for resource naming and tagging"
  type        = string
  default     = "wordpress-demo"
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "db_password" {
  description = "Password for the MySQL database (minimum 8 characters)"
  type        = string
  sensitive   = true
  
  validation {
    condition = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the WordPress site"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_backup" {
  description = "Enable automated backups for RDS"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
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

variable "public_subnet_ids" {
  description = "List of existing public subnet IDs for RDS when publicly accessible (minimum 2 subnets in different AZs)"
  type        = list(string)
  
  validation {
    condition = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnet IDs are required for publicly accessible RDS."
  }
  
  validation {
    condition = alltrue([
      for subnet_id in var.public_subnet_ids : can(regex("^subnet-[a-z0-9]+$", subnet_id))
    ])
    error_message = "All subnet IDs must be valid subnet identifiers starting with 'subnet-'."
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