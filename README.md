# WordPress Demo on AWS with HCP Terraform

Este módulo de Terraform despliega una infraestructura básica en AWS para ejecutar WordPress, ideal para demostraciones de HCP Terraform.

## Recursos creados

- **VPC** con subnets públicas y privadas
- **Instancia EC2** (Amazon Linux 2) con WordPress preinstalado
- **Base de datos RDS MySQL** para WordPress
- **Security Groups** configurados apropiadamente
- **Internet Gateway** y tablas de rutas

## Prerrequisitos

1. AWS CLI configurado con credenciales válidas
2. Terraform >= 1.0 instalado
3. Cuenta de HCP Terraform (opcional, pero recomendado)

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
| `instance_type` | Tipo de instancia EC2 | string | `t3.micro` |
| `db_instance_class` | Clase de instancia RDS | string | `db.t3.micro` |
| `db_password` | Contraseña de la base de datos | string | - |

## Outputs

- `wordpress_url`: URL para acceder a WordPress
- `wordpress_public_ip`: IP pública del servidor
- `database_endpoint`: Endpoint de la base de datos (sensible)
- `database_name`: Nombre de la base de datos
- `vpc_id`: ID de la VPC creada

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