# Projeto RDS - Tech Challenge

Este projeto contém a infraestrutura do banco de dados PostgreSQL (RDS) para o Tech Challenge.

**🎯 Abordagem**: Infraestrutura independente - Cria sua própria VPC e recursos de rede.

## Estrutura

- `main.tf` - VPC, subnets, RDS e configurações de rede
- `variables.tf` - Variáveis do projeto
- `outputs.tf` - Outputs do projeto (incluindo informações da VPC)
- `provider.tf` - Configuração do provider AWS
- `terraform.tfvars` - Configuração das variáveis

## Como usar

**⚠️ IMPORTANTE: Execute este projeto ANTES do infra-kubernetes!**

1. Execute:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Recursos criados

- **VPC dedicada para o banco** (10.1.0.0/16)
- **Subnets públicas** em múltiplas AZs
- **Internet Gateway e Route Tables**
- **RDS PostgreSQL Instance**
- **Security Group** (permite acesso da VPC do EKS)
- **Suporte para VPC Peering** (configurado pelo projeto infra-kubernetes)

## Dependências

- **Nenhuma!** Este projeto é completamente independente
- O projeto `infra-kubernetes` irá consumir os dados deste projeto via data sources

## Conectividade

- A conectividade com o EKS é estabelecida via **VPC Peering**
- O projeto `infra-kubernetes` cria o peering e as rotas necessárias
- Security Group permite acesso apenas da CIDR do EKS (10.0.0.0/16)

## Recursos criados

- RDS PostgreSQL Instance
- DB Subnet Group
- Security Group para RDS

## Outputs disponíveis

- `rds_hostname` - Hostname da instância RDS
- `rds_port` - Porta da instância RDS
- `rds_username` - Username do banco
- `database_name` - Nome do banco
- `rds_endpoint` - Endpoint completo da instância
- `security_group_id` - ID do security group do RDS