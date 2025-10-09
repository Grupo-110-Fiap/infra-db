# Terraform Cloud Error Resolution

## 🚨 Problem Summary

Your Terraform Cloud run failed with multiple errors indicating state corruption and provider version conflicts. The main issues are:

### 1. **Mixed Resource State**
The `infra-db` project state contains:
- ✅ Database resources (correct)
- ❌ Kubernetes resources (should be in `infra-kubernetes`)
- ❌ EKS cluster resources (should be in `infra-kubernetes`)
- ❌ Old VPC resources (should be in `infra-kubernetes`)

### 2. **Provider Version Conflicts**
- Error: `unsupported attribute "account_id"`
- Caused by AWS provider version mismatch in state

### 3. **Kubernetes Connection Issues**
- Error: `dial tcp [::1]:80: connect: connection refused`
- Kubernetes provider trying to connect to localhost

## 🔧 **Immediate Solution**

### Step 1: Run Quick Fix
```bash
cd /Users/guilherme.munhoz/Workspace/Fiap/infra-db
./quick_fix.sh
```

### Step 2: Clean State (if needed)
```bash
./cleanup_state.sh
```

### Step 3: Verify and Apply
```bash
terraform plan    # Should only show DB resources
terraform apply   # If plan looks correct
```

## 📋 **What Should Be in Each Project**

### `infra-db` (Database Infrastructure)
- ✅ `aws_vpc.db_vpc`
- ✅ `aws_subnet.db_public[*]`  
- ✅ `aws_internet_gateway.db_igw`
- ✅ `aws_route_table.db_public`
- ✅ `aws_route_table_association.db_public[*]`
- ✅ `aws_db_subnet_group.main`
- ✅ `aws_security_group.rds`
- ✅ `aws_db_instance.postgres-v2`

### `infra-kubernetes` (EKS Infrastructure)
- ✅ `aws_vpc.main` (EKS VPC)
- ✅ `aws_eks_cluster.main`
- ✅ `aws_eks_node_group.main`
- ✅ `kubernetes_namespace.pedidos`
- ✅ `kubernetes_deployment.pedidos_api`
- ✅ All other EKS and Kubernetes resources

## 🚀 **After Resolution**

Once the state is cleaned:

1. **Complete `infra-db`** deployment
2. **Move to `infra-kubernetes`** project  
3. **Set up VPC peering** between the two VPCs
4. **Deploy application** resources

## 📞 **Support Files Created**

- `TROUBLESHOOTING.md` - Detailed troubleshooting steps
- `cleanup_state.sh` - Automated state cleanup
- `quick_fix.sh` - Quick configuration check and fix
- Updated `provider.tf` - More specific AWS provider version

Run the quick fix first, then proceed based on the results!