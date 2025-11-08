# Outputs for HTML Website Demo
output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.web.public_dns}"
}

output "website_about_url" {
  description = "URL to access the about page"
  value       = "http://${aws_instance.web.public_dns}/about.html"
}

output "website_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "website_public_dns" {
  description = "Public DNS name of the web server"
  value       = aws_instance.web.public_dns
}

output "security_group_web_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role for EC2 SSM access"
  value       = aws_iam_role.ec2_ssm_role.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "key_pair_name" {
  description = "Name of the key pair used for SSH access"
  value       = var.key_pair_name
}

output "deployment_instructions" {
  description = "Instructions for accessing the website after deployment"
  value = <<-EOT
    🚀 Deployment Complete! 
    
    📝 Next Steps:
    1. Wait 2-3 minutes for the website installation to complete
    2. Visit your website: http://${aws_instance.web.public_dns}
    3. Check out the about page: http://${aws_instance.web.public_dns}/about.html
    
    🔧 Admin Access:
    - SSH Access: ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.web.public_ip}
    - SSM Session: Use AWS Systems Manager Session Manager
    
    🌐 Website Features:
    - Modern HTML5 responsive design
    - Multiple pages (home and about)
    - CSS3 with gradient backgrounds and glassmorphism effects
    - Information about the Terraform deployment
    
    💡 Note: 
    - The website is ready to use immediately after EC2 initialization
    - EC2 instance has SSM Agent configured for secure access
    - All content is served by Apache HTTP Server
  EOT
}