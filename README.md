# Standalone RDS Infrastructure

This Terraform project creates a standalone PostgreSQL RDS instance with its own VPC and networking infrastructure. It does not depend on any external resources.

## Structure

- `main.tf` - VPC, subnets, RDS and networking configuration
- `variables.tf` - Project variables
- `outputs.tf` - Project outputs (including RDS and VPC information)
- `provider.tf` - AWS provider configuration
- `terraform.tfvars` - Variable values

## Usage

This project is completely standalone and can be deployed independently:

1. **Set your database password** in `terraform.tfvars`
2. **Configure access** by adding CIDR blocks to `allowed_cidr_blocks` if needed
3. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Resources Created

- **Dedicated VPC for database** (10.1.0.0/16 by default)
- **Public subnets** across multiple availability zones
- **Internet Gateway and Route Tables**
- **PostgreSQL RDS Instance** (v17.5)
- **Security Group** with configurable access rules
- **DB Subnet Group** for multi-AZ deployment

## Dependencies

- **None!** This project is completely standalone
- No external VPCs, subnets, or security groups required
- Creates all necessary networking infrastructure

## Security Configuration

- **Default Access**: Only from within the DB VPC (10.1.0.0/16)
- **External Access**: Configure `allowed_cidr_blocks` variable to grant access from additional networks
- **Public Access**: RDS is set to publicly accessible but protected by security groups

Example to allow access from your application VPC:
```hcl
allowed_cidr_blocks = ["10.0.0.0/16"]  # Your application VPC CIDR
```

## Database Configuration

- **Engine**: PostgreSQL 17.5
- **Instance Class**: db.t4g.micro
- **Storage**: 20GB (auto-scaling to 100GB)
- **Database Name**: gestor_pedidos_db
- **Username**: fiap_arch

## Available Outputs

- `rds_hostname` - RDS instance hostname
- `rds_port` - RDS instance port
- `rds_username` - Database username
- `database_name` - Database name
- `rds_endpoint` - Complete RDS endpoint
- `security_group_id` - RDS security group ID
- `db_vpc_id` - Database VPC ID
- `db_vpc_cidr` - Database VPC CIDR block
- `db_subnet_ids` - Database subnet IDs