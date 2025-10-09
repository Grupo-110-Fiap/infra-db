# Troubleshooting Terraform State Issues

## 🚨 Current Problems Identified

### 1. State Corruption
The Terraform state contains mixed resources from different projects:
- AWS infrastructure resources (correct for infra-db)
- Kubernetes resources (should be in infra-kubernetes)
- EKS cluster resources (should be in infra-kubernetes)

### 2. Provider Version Conflicts
Error: `unsupported attribute "account_id"` indicates AWS provider version mismatch.

### 3. Kubernetes Connection Errors
Error: `dial tcp [::1]:80: connect: connection refused` - Kubernetes provider trying to connect to localhost.

## 🔧 Solution Steps

### Step 1: Clean State (Nuclear Option)
If you can recreate the infrastructure from scratch:

```bash
# 1. Backup current state
cd /Users/guilherme.munhoz/Workspace/Fiap/infra-db
terraform state pull > terraform.tfstate.backup

# 2. Remove all resources from state (without destroying them)
terraform state list | xargs -I {} terraform state rm {}

# 3. Re-import only the resources that belong to infra-db
# (After manually identifying which resources should remain)
```

### Step 2: Selective State Removal
Remove only the problematic resources:

```bash
# Remove Kubernetes resources
terraform state rm kubernetes_namespace.pedidos
terraform state rm kubernetes_config_map.pedidos_config
terraform state rm kubernetes_secret.pedidos_secret
terraform state rm kubernetes_deployment.pedidos_api

# Remove EKS resources (should be in infra-kubernetes)
terraform state rm aws_eks_cluster.main
terraform state rm aws_eks_node_group.main
terraform state rm aws_iam_role.eks_cluster
terraform state rm aws_iam_role.eks_node_group
terraform state rm aws_iam_role_policy_attachment.eks_cluster_policy
terraform state rm aws_iam_role_policy_attachment.eks_worker_node_policy
terraform state rm aws_iam_role_policy_attachment.eks_cni_policy
terraform state rm aws_iam_role_policy_attachment.eks_container_registry_policy

# Remove networking resources that should be in infra-kubernetes
terraform state rm aws_vpc.main
terraform state rm aws_subnet.public
terraform state rm aws_subnet.private
terraform state rm aws_route_table.public
terraform state rm aws_route_table.private
terraform state rm aws_internet_gateway.main
terraform state rm aws_nat_gateway.main
terraform state rm aws_eip.nat
terraform state rm aws_route_table_association.public
terraform state rm aws_route_table_association.private

# Remove ECR (should be in infra-kubernetes)
terraform state rm aws_ecr_repository.pedidos_api
```

### Step 3: Update Provider Constraints
Ensure provider version compatibility:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"  # More specific version
    }
  }
}
```

### Step 4: Resources that SHOULD remain in infra-db:
- `aws_vpc.db_vpc`
- `aws_subnet.db_public`
- `aws_internet_gateway.db_igw`
- `aws_route_table.db_public`
- `aws_route_table_association.db_public`
- `aws_db_subnet_group.main`
- `aws_security_group.rds`
- `aws_db_instance.postgres-v2`

### Step 5: Verify and Apply
```bash
terraform plan  # Should only show DB-related resources
terraform apply # If plan looks correct
```

## 🚀 Alternative: Fresh Start Approach

If the above is too complex, consider:

1. **Destroy everything** (if acceptable):
   ```bash
   terraform destroy
   ```

2. **Create new state** with only DB resources:
   ```bash
   terraform init -reconfigure
   terraform plan
   terraform apply
   ```

3. **Then proceed** with infra-kubernetes in the correct order.

## 📋 Recommended Action Plan

Given the complexity, I recommend:

1. **Backup current state**
2. **Use Terraform Cloud's state versioning** to rollback if needed
3. **Remove problematic resources from state** using the selective approach
4. **Run terraform plan** to verify only DB resources remain
5. **Proceed with the corrected configuration**

This will separate concerns properly and allow both projects to work independently.