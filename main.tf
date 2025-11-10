# Demo HCP Terraform - Basic HTML Website on AWS
# This configuration creates a simple static website with EC2
# Version constraints are defined in versions.tf

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner = var.owner
    }
  }
}

# Variables are defined in variables.tf

# Data sources
# data "aws_availability_zones" "available" {
#   state = "available"
# }

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
    Name  = "${var.project_name}-ec2-ssm-role"
    Owner = var.owner
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
    Name  = "${var.project_name}-ec2-profile"
    Owner = var.owner
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

  # SSH access from specific IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["38.253.158.165/32"]
    description = "SSH access from specific IP"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.project_name}-web-sg"
    Owner = var.owner
  }
}

# User Data Script for Basic HTML Website
locals {
  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a basic HTML website
cd /var/www/html

# Create index.html with a basic website
cat <<'HTML' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demo HCP Terraform</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .container {
            text-align: center;
            max-width: 800px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        h2 {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .info {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 10px;
            margin: 1rem 0;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        .feature {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
        }
        .footer {
            margin-top: 2rem;
            opacity: 0.7;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Demo HCP Terraform</h1>
        <h2>Sitio Web Desplegado con Terraform</h2>
        
        <div class="info">
            <h3>✅ Despliegue Exitoso</h3>
            <p>Esta página web ha sido desplegada automáticamente usando HashiCorp Terraform y HCP Terraform.</p>
        </div>

        <div class="features">
            <div class="feature">
                <h4>🔧 Infraestructura como Código</h4>
                <p>EC2 + Apache HTTP Server</p>
            </div>
            <div class="feature">
                <h4>☁️ AWS Cloud</h4>
                <p>Desplegado en Amazon Web Services</p>
            </div>
            <div class="feature">
                <h4>🔒 Seguridad</h4>
                <p>Security Groups + IAM + SSM</p>
            </div>
            <div class="feature">
                <h4>📦 Automatización</h4>
                <p>User Data Script</p>
            </div>
        </div>

        <div class="footer">
            <p>Powered by HashiCorp Terraform • Desplegado en $(date)</p>
        </div>
    </div>
</body>
</html>
HTML

# Create an about page
cat <<'HTML' > about.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acerca de - Demo HCP Terraform</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .container {
            text-align: center;
            max-width: 800px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
        }
        .nav {
            margin-bottom: 2rem;
        }
        .nav a {
            color: white;
            text-decoration: none;
            margin: 0 1rem;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 5px;
        }
        .nav a:hover {
            background: rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="index.html">🏠 Inicio</a>
            <a href="about.html">📋 Acerca de</a>
        </div>
        
        <h1>📋 Acerca de este sitio</h1>
        
        <div style="text-align: left; max-width: 600px;">
            <h3>🛠️ Tecnologías utilizadas:</h3>
            <ul>
                <li><strong>HashiCorp Terraform</strong> - Infraestructura como código</li>
                <li><strong>HCP Terraform</strong> - Gestión de estado remoto</li>
                <li><strong>Amazon EC2</strong> - Instancia de servidor web</li>
                <li><strong>Apache HTTP Server</strong> - Servidor web</li>
                <li><strong>HTML5 + CSS3</strong> - Frontend</li>
            </ul>

            <h3>🏗️ Arquitectura:</h3>
            <ul>
                <li>VPC existente reutilizada</li>
                <li>Subnet pública para el servidor web</li>
                <li>Security Group con acceso HTTP/HTTPS/SSH</li>
                <li>IAM Role para AWS Systems Manager</li>
                <li>User Data para configuración automática</li>
            </ul>
        </div>
        
        <div style="margin-top: 2rem;">
            <a href="index.html" style="color: white; text-decoration: none; padding: 1rem 2rem; background: rgba(255, 255, 255, 0.2); border-radius: 10px;">← Volver al inicio</a>
        </div>
    </div>
</body>
</html>
HTML

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart httpd
EOF
  )
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_pair_name

  user_data = local.user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name  = "${var.project_name}-web-server"
    Owner = var.owner
  }
}

# Outputs are defined in outputs.tf
