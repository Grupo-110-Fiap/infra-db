# Ordem de Execução - Projetos separados

## ✅ Nova arquitetura (Database-First)

### 📋 Ordem CORRETA de execução:

#### 1️⃣ **Primeiro: infra-db**
```bash
cd /Users/guilherme.munhoz/Workspace/Fiap/infra-db
terraform init
terraform plan
terraform apply
```

**O que cria:**
- VPC dedicada para o banco (10.1.0.0/16)
- Subnets públicas em múltiplas AZs
- RDS PostgreSQL
- Security Group (preparado para EKS)

#### 2️⃣ **Segundo: infra-kubernetes**
```bash
cd /Users/guilherme.munhoz/Workspace/Fiap/infra-kubernetes
terraform init
terraform plan
terraform apply
```

**O que cria:**
- VPC do EKS (10.0.0.0/16)
- EKS Cluster e Workers
- VPC Peering entre as duas VPCs
- Routes para comunicação entre VPCs
- Recursos Kubernetes (usa data source para buscar RDS)

## 🔧 Arquitetura da solução:

```
┌─────────────────┐    VPC Peering    ┌─────────────────┐
│   EKS VPC       │◄──────────────────►│   DB VPC        │
│  10.0.0.0/16    │                   │  10.1.0.0/16    │
│                 │                   │                 │
│ ┌─────────────┐ │                   │ ┌─────────────┐ │
│ │ EKS Cluster │ │                   │ │ RDS Postgres│ │
│ │   Pods      │ │                   │ │             │ │
│ └─────────────┘ │                   │ └─────────────┘ │
└─────────────────┘                   └─────────────────┘
```

## 🎯 Vantagens desta abordagem:

1. **Banco independente**: Pode ser criado/destruído sem afetar o EKS
2. **Segurança**: VPCs separadas com comunicação controlada
3. **Escalabilidade**: Cada projeto pode evoluir independentemente
4. **Data Sources**: infra-kubernetes busca RDS automaticamente
5. **Zero configuração manual**: Não precisa copiar/colar IDs entre projetos

## 🔍 Data Sources utilizados:

### No infra-kubernetes:
```hcl
data "aws_db_instance" "postgres" {
  db_instance_identifier = "${var.cluster_name}-postgres"
}

data "aws_vpc" "db_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}-db-vpc"]
  }
}
```

### No infra-db:
```hcl
data "aws_vpc_peering_connection" "eks_to_db" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}-eks-to-db-peering"]
  }
}
```