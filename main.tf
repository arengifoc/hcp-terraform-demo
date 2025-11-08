# Demo HCP Terraform - WordPress on AWS
# This configuration creates a simple WordPress setup with EC2 and RDS
# Version constraints are defined in versions.tf

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Variables are defined in variables.tf

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# IAM Role for EC2 SSM access
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-ssm-role"
  }
}

# Attach AWS managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name = "${var.project_name}-ec2-profile"
  }
}

# Security Group for Web Server
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = var.vpc_id

  # HTTP/HTTPS access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # SSH access (restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = var.vpc_id

  # MySQL access from web server
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # MySQL access from Internet (for external tools)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL access from Internet"
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "wordpress" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = "wordpress"
  username = "admin"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  # Make RDS publicly accessible
  publicly_accessible = true

  backup_retention_period = var.enable_backup ? var.backup_retention_period : 0
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-database"
  }
}

# User Data Script for WordPress Installation
locals {
  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd mysql php php-mysqlnd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download and configure WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Create WordPress configuration
cp wp-config-sample.php wp-config.php

# Update wp-config.php with database details
sed -i "s/database_name_here/wordpress/g" wp-config.php
sed -i "s/username_here/admin/g" wp-config.php
sed -i "s/password_here/${var.db_password}/g" wp-config.php
sed -i "s/localhost/${aws_db_instance.wordpress.endpoint}/g" wp-config.php

# Generate WordPress salts
SALT_URL="https://api.wordpress.org/secret-key/1.1/salt/"
SALTS=$(curl -s $SALT_URL)
printf '%s\n' "$SALTS" > /tmp/wp-salts.txt

# Replace the salt section in wp-config.php
sed -i '/AUTH_KEY/,$d' wp-config.php
cat /tmp/wp-salts.txt >> wp-config.php
echo "\$table_prefix = 'wp_';" >> wp-config.php
echo "if ( ! defined( 'ABSPATH' ) ) {" >> wp-config.php
echo "    define( 'ABSPATH', __DIR__ . '/' );" >> wp-config.php
echo "}" >> wp-config.php
echo "require_once ABSPATH . 'wp-settings.php';" >> wp-config.php

# Restart Apache
systemctl restart httpd

# Create a simple index page while WordPress loads
echo "<h1>WordPress is being configured...</h1><p>Please wait a few minutes for the installation to complete.</p>" > /var/www/html/index.html
EOF
  )
}

# EC2 Instance
resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type         = var.instance_type
  subnet_id             = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-web-server"
  }

  depends_on = [aws_db_instance.wordpress]
}

# Outputs are defined in outputs.tf