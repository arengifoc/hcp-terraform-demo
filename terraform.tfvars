# Terraform variables file
# Customize these values according to your environment

# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "html-demo"

# Existing Network Resources
# Replace these with your actual VPC and subnet IDs
vpc_id            = "vpc-0a48d8d169b6283c9"
public_subnet_id  = "subnet-09640817994be2dac"

# EC2 Configuration
instance_type = "t3.micro"
key_pair_name = "kp-arengifo"  # Change to your key pair name
