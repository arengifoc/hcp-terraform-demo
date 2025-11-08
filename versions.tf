# Terraform and Provider Version Constraints
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment for HCP Terraform
  # cloud {
  #   organization = "your-org-name"
  #   workspaces {
  #     name = "wordpress-demo"
  #   }
  # }
}