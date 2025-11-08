# WordPress Demo on AWS with HCP Terraform

Este módulo de Terraform despliega una infraestructura básica en AWS para ejecutar WordPress, utilizando recursos de red existentes.

## Recursos creados

- **Instancia EC2** (Amazon Linux 2) con WordPress preinstalado
- **Base de datos RDS MySQL** para WordPress
- **Security Groups** configurados apropiadamente

## Prerrequisitos

1. AWS CLI configurado con credenciales válidas
2. Terraform >= 1.0 instalado
3. **VPC existente** con:
   - Al menos una subnet pública (para EC2)
   - Al menos dos subnets privadas en diferentes AZs (para RDS)
   - Internet Gateway configurado en la subnet pública
4. Cuenta de HCP Terraform (opcional, pero recomendado)

## Uso

### Configuración local

1. Clona este repositorio
2. Copia el archivo de ejemplo de variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edita `terraform.tfvars` con tus valores:
   ```hcl
   aws_region = "us-east-1"
   project_name = "mi-wordpress-demo"
   
   # IDs de tus recursos de red existentes
   vpc_id = "vpc-0123456789abcdef0"
   public_subnet_id = "subnet-0123456789abcdef0"
   private_subnet_ids = [
     "subnet-0123456789abcdef1",
     "subnet-0123456789abcdef2"
   ]
   
   db_password = "tu-password-seguro"
   ```
4. Ejecuta Terraform:
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
   - `private_subnet_ids`
   - `db_password` (marca como sensible)
5. Ejecuta el plan desde HCP Terraform

## Acceso a WordPress

Una vez completado el despliegue:

1. Espera 5-10 minutos para que WordPress se configure completamente
2. Accede a la URL mostrada en los outputs
3. Completa la configuración inicial de WordPress

## Variables

| Variable | Descripción | Tipo | Valor por defecto |
|----------|-------------|------|-------------------|
| `aws_region` | Región de AWS | string | `us-east-1` |
| `project_name` | Nombre del proyecto para etiquetas | string | `wordpress-demo` |
| `vpc_id` | ID de la VPC existente | string | - |
| `public_subnet_id` | ID de la subnet pública existente | string | - |
| `private_subnet_ids` | Lista de IDs de subnets privadas (mínimo 2) | list(string) | - |
| `instance_type` | Tipo de instancia EC2 | string | `t3.micro` |
| `db_instance_class` | Clase de instancia RDS | string | `db.t3.micro` |
| `db_password` | Contraseña de la base de datos | string | - |

## Outputs

- `wordpress_url`: URL para acceder a WordPress
- `wordpress_public_ip`: IP pública del servidor
- `database_endpoint`: Endpoint de la base de datos (sensible)
- `database_name`: Nombre de la base de datos
- `security_group_web_id`: ID del security group web
- `security_group_rds_id`: ID del security group RDS

## Costos estimados

Para recursos en `us-east-1` con configuración por defecto:
- EC2 t3.micro: ~$8.50/mes
- RDS db.t3.micro: ~$15/mes
- Almacenamiento y transferencia: ~$2-5/mes

**Total estimado: $25-30/mes**

## Limpieza

Para eliminar todos los recursos:

```bash
terraform destroy
```

## Seguridad

⚠️ **Importante**: Esta configuración es para demostraciones únicamente. Para producción, considera:

- Usar HTTPS con certificados SSL
- Configurar acceso SSH más restrictivo
- Usar sistemas de gestión de secretos para contraseñas
- Implementar copias de seguridad regulares
- Configurar monitoring y alertas

## Solución de problemas

### WordPress no se carga
- Verifica que la instancia EC2 esté running
- Espera 10-15 minutos para la configuración inicial
- Revisa los logs del sistema en la consola EC2

### Error de conexión a la base de datos
- Verifica que RDS esté disponible
- Confirma la configuración de security groups
- Revisa la conectividad de red entre subnets