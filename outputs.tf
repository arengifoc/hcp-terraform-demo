# Outputs for WordPress Demo
output "wordpress_url" {
  description = "URL to access the WordPress website"
  value       = "http://${aws_instance.wordpress.public_dns}"
}

output "wordpress_admin_url" {
  description = "URL to access WordPress admin panel"
  value       = "http://${aws_instance.wordpress.public_dns}/wp-admin"
}

output "wordpress_public_ip" {
  description = "Public IP address of the WordPress server"
  value       = aws_instance.wordpress.public_ip
}

output "wordpress_public_dns" {
  description = "Public DNS name of the WordPress server"
  value       = aws_instance.wordpress.public_dns
}

output "database_endpoint" {
  description = "RDS MySQL database endpoint"
  value       = aws_db_instance.wordpress.endpoint
  sensitive   = true
}

output "database_name" {
  description = "Name of the WordPress database"
  value       = aws_db_instance.wordpress.db_name
}

output "database_username" {
  description = "Username for the WordPress database"
  value       = aws_db_instance.wordpress.username
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC created for this deployment"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "security_group_web_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "security_group_rds_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "deployment_instructions" {
  description = "Instructions for accessing WordPress after deployment"
  value = <<-EOT
    Deployment Complete! 
    
    📝 Next Steps:
    1. Wait 5-10 minutes for WordPress installation to complete
    2. Visit: http://${aws_instance.wordpress.public_dns}
    3. Complete WordPress setup using:
       - Database: wordpress
       - Username: admin
       - Password: [the password you configured]
       - Host: ${aws_db_instance.wordpress.endpoint}
    
    🔧 Admin Access:
    - WordPress Admin: http://${aws_instance.wordpress.public_dns}/wp-admin
    - SSH Access: ssh -i your-key.pem ec2-user@${aws_instance.wordpress.public_ip}
    
    💡 Note: If WordPress shows an error, wait a few more minutes for the installation to complete.
  EOT
}