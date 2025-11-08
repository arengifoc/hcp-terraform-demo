# Example terraform.tfvars file
# Copy this to terraform.tfvars and customize the values

# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "wordpress-demo"

# Existing Network Resources
# Replace these with your actual VPC and subnet IDs
vpc_id            = "vpc-0a48d8d169b6283c9"
public_subnet_id  = "subnet-09640817994be2dac"
public_subnet_ids = [
  "subnet-09640817994be2dac",
  "subnet-08ecf0a6530733061"
]

# EC2 Configuration
instance_type = "t3.micro"

# RDS Configuration
db_instance_class = "db.t3.micro"
