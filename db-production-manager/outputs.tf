# RDS Outputs
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.postgres-v2.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres-v2.port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.postgres-v2.username
  sensitive   = true
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.postgres-v2.db_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres-v2.endpoint
  sensitive   = true
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

# VPC outputs
output "db_vpc_id" {
  description = "Database VPC ID"
  value       = aws_vpc.db_vpc.id
}

output "db_vpc_cidr" {
  description = "Database VPC CIDR"
  value       = aws_vpc.db_vpc.cidr_block
}

output "db_subnet_ids" {
  description = "Database subnet IDs"
  value       = aws_subnet.db_public[*].id
}

output "database_url" {
  description = "Database connection URL"
  value       = "postgresql://fiap_arch:fiap_arch@${aws_db_instance.postgres-v2.endpoint}/${aws_db_instance.postgres-v2.db_name}"
  sensitive   = true
}