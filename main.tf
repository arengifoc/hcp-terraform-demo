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

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Private Subnet 1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-private-subnet-1"
  }
}

# Private Subnet 2 (required for RDS subnet group)
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.project_name}-private-subnet-2"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group for Web Server
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = aws_vpc.main.id

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
  vpc_id      = aws_vpc.main.id

  # MySQL access from web server
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

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
  subnet_id             = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

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