# HTML Website Demo on AWS with HCP Terraform

Este módulo de Terraform despliega una infraestructura básica en AWS para ejecutar un sitio web HTML estático, utilizando recursos de red existentes.

## Recursos creados

- **Instancia EC2** (Amazon Linux 2) con Apache HTTP Server
- **Security Group** para acceso HTTP/HTTPS/SSH
- **IAM Role** para AWS Systems Manager
- **Sitio web HTML** con diseño moderno y responsive

## Prerrequisitos

1. AWS CLI configurado con credenciales válidas
2. Terraform >= 1.0 instalado
3. **VPC existente** con:
   - Al menos una subnet pública (para EC2)
   - Internet Gateway configurado en la subnet pública
4. **AWS Key Pair** existente para acceso SSH
5. Cuenta de HCP Terraform (opcional, pero recomendado)

## Uso

### Configuración local

1. Clona este repositorio
2. Edita el archivo `terraform.tfvars` con tus valores reales:
   ```hcl
   aws_region = "us-east-1"
   project_name = "mi-sitio-web"
   
   # IDs de tus recursos de red existentes
   vpc_id = "vpc-tu-vpc-real"
   public_subnet_id = "subnet-tu-subnet-publica"
   
   key_pair_name = "tu-keypair"
   ```
3. Ejecuta Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Configuración con HCP Terraform

1. Crea un workspace en HCP Terraform
2. Conecta tu repositorio Git
3. Configura las variables de entorno:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
4. Configura las variables de Terraform:
   - `aws_region`
   - `project_name` 
   - `vpc_id`
   - `public_subnet_id`
   - `key_pair_name`
5. Ejecuta el plan desde HCP Terraform

## Acceso al sitio web

Una vez completado el despliegue:

1. Espera 2-3 minutos para que el sitio web se configure completamente
2. Accede a la URL mostrada en los outputs
3. ¡Disfruta de tu sitio web HTML moderno!

## Variables

| Variable | Descripción | Tipo | Valor por defecto |
|----------|-------------|------|-------------------|
| `aws_region` | Región de AWS | string | `us-east-1` |
| `project_name` | Nombre del proyecto para etiquetas | string | `html-demo` |
| `vpc_id` | ID de la VPC existente | string | - |
| `public_subnet_id` | ID de la subnet pública existente (para EC2) | string | - |
| `instance_type` | Tipo de instancia EC2 | string | `t3.micro` |
| `key_pair_name` | Nombre del key pair para acceso SSH | string | `kp-arengifo` |
| `allowed_cidr_blocks` | CIDR blocks permitidos para acceso web | list(string) | `["0.0.0.0/0"]` |

## Outputs

- `website_url`: URL para acceder al sitio web
- `website_about_url`: URL para acceder a la página "acerca de"
- `website_public_ip`: IP pública del servidor web
- `website_public_dns`: DNS público del servidor web
- `security_group_web_id`: ID del security group web
- `iam_role_arn`: ARN del rol IAM para SSM
- `instance_profile_name`: Nombre del instance profile
- `key_pair_name`: Nombre del keypair usado

## Características del sitio web

### 🎨 **Diseño moderno**
- HTML5 semántico y responsive
- CSS3 con gradientes y efectos glassmorphism
- Diseño adaptable a dispositivos móviles y desktop

### 🖥️ **Funcionalidades**
- Página principal con información del proyecto
- Página "acerca de" con detalles técnicos
- Navegación entre páginas
- Información sobre tecnologías utilizadas

### 🔒 **Seguridad**
- **SSH restringido**: Acceso SSH solo desde IP específica (38.253.158.165)
- **SSM Agent**: Configuración de IAM para AWS Systems Manager
- **Acceso alternativo**: Permite administración segura sin SSH directo
- **Security Groups**: Configurados con principio de menor privilegio

### 🚀 **Despliegue automático**
- Configuración completa mediante User Data
- Apache HTTP Server preconfigurado
- Contenido HTML generado automáticamente

## Costos estimados

Para recursos en `us-east-1` con configuración por defecto:
- EC2 t3.micro: ~$8.50/mes
- Almacenamiento EBS (20GB): ~$2/mes
- Transferencia de datos: ~$1-2/mes

**Total estimado: $10-12/mes**

## Limpieza

Para eliminar todos los recursos:

```bash
terraform destroy
```

## Seguridad

✅ **Configuración de seguridad implementada:**

- **SSH restringido**: Solo accesible desde la IP 38.253.158.165
- **HTTP/HTTPS**: Accesible desde cualquier IP (para sitio web público)
- **IAM Role**: Configurado para acceso seguro via SSM

⚠️ **Para producción, considera también:**

- Usar HTTPS con certificados SSL
- Usar sistemas de gestión de secretos para credenciales
- Implementar copias de seguridad regulares
- Configurar monitoring y alertas

## Solución de problemas

### El sitio web no se carga
- Verifica que la instancia EC2 esté running
- Espera 3-5 minutos para la configuración inicial
- Revisa los logs del sistema en la consola EC2
- Verifica que el Security Group permita tráfico HTTP (puerto 80)

### Error de conexión
- Confirma la configuración del security group
- Verifica la conectividad de red de la subnet pública
- Asegúrate de que la subnet tenga un Internet Gateway configurado