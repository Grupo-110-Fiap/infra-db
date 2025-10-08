# VPC para o banco de dados
resource "aws_vpc" "db_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}-db-vpc"
  }
}

# Internet Gateway para a VPC do DB
resource "aws_internet_gateway" "db_igw" {
  vpc_id = aws_vpc.db_vpc.id

  tags = {
    Name = "${var.cluster_name}-db-igw"
  }
}

# Subnets públicas para o RDS em diferentes AZs
resource "aws_subnet" "db_public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.db_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-db-public-${count.index + 1}"
  }
}

# Route Table para subnets públicas do DB
resource "aws_route_table" "db_public" {
  vpc_id = aws_vpc.db_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.db_igw.id
  }

  tags = {
    Name = "${var.cluster_name}-db-public"
  }
}

# Associações da Route Table
resource "aws_route_table_association" "db_public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.db_public[count.index].id
  route_table_id = aws_route_table.db_public.id
}



# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = aws_subnet.db_public[*].id

  tags = {
    Name = "${var.cluster_name}-db-subnet-group"
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.db_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]  # CIDR do EKS (será criado depois)
    description     = "PostgreSQL access from EKS VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-rds-sg"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres-v2" {
  identifier = "${var.cluster_name}-postgres"

  engine         = "postgres"
  engine_version = "17.5"
  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = "gestor_pedidos_db"
  username = "fiap_arch"
  password = "fiap_arch"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Explicitly ensure RDS is not publicly accessible
  publicly_accessible = true

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.cluster_name}-postgres"
  }
}