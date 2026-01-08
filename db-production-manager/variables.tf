variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "production-manager-prod"
}

variable "vpc_cidr" {
  description = "CIDR block for DB VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default = "terraform-rds-state-bucket-asdajrbga"
}

variable "db_password" {
  description = "Password for the RDS PostgreSQL instance"
  type        = string
  sensitive   = true
  default     = "StrongPass123!"

}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS instance"
  type        = list(string)
  default     = []  # Empty by default for security - populate as needed
}