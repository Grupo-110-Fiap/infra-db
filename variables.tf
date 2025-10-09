variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "techchallenge"
}

variable "vpc_cidr" {
  description = "CIDR block for DB VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default = "terraform-rds-state-bucket"
}

variable "db_password" {
  description = "Password for the RDS PostgreSQL instance"
  type        = string
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS instance"
  type        = list(string)
  default     = []  # Empty by default for security - populate as needed
}