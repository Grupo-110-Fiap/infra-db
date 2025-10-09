#!/bin/bash

# Script to clean up mixed Terraform state in infra-db project
# This removes resources that should be in the infra-kubernetes project

set -e

echo "🧹 Cleaning up Terraform state for infra-db project"
echo "This will remove resources that belong in infra-kubernetes"

# Backup current state
echo "📦 Creating state backup..."
terraform state pull > "terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"

# List all current resources
echo "📋 Current resources in state:"
terraform state list

# Remove Kubernetes resources (these should be in infra-kubernetes)
echo "🗑️  Removing Kubernetes resources..."
KUBERNETES_RESOURCES=(
    "kubernetes_namespace.pedidos"
    "kubernetes_config_map.pedidos_config" 
    "kubernetes_secret.pedidos_secret"
    "kubernetes_deployment.pedidos_api"
    "kubernetes_service.pedidos_api"
)

for resource in "${KUBERNETES_RESOURCES[@]}"; do
    if terraform state list | grep -q "^${resource}$"; then
        echo "Removing: $resource"
        terraform state rm "$resource" || echo "Failed to remove $resource (may not exist)"
    fi
done

# Remove EKS resources (these should be in infra-kubernetes)
echo "🗑️  Removing EKS resources..."
EKS_RESOURCES=(
    "aws_eks_cluster.main"
    "aws_eks_node_group.main"
    "aws_iam_role.eks_cluster"
    "aws_iam_role.eks_node_group"
    "aws_iam_role_policy_attachment.eks_cluster_policy"
    "aws_iam_role_policy_attachment.eks_worker_node_policy"
    "aws_iam_role_policy_attachment.eks_cni_policy"
    "aws_iam_role_policy_attachment.eks_container_registry_policy"
    "aws_security_group.eks_cluster"
    "aws_security_group.eks_nodes"
)

for resource in "${EKS_RESOURCES[@]}"; do
    if terraform state list | grep -q "^${resource}$"; then
        echo "Removing: $resource"
        terraform state rm "$resource" || echo "Failed to remove $resource (may not exist)"
    fi
done

# Remove old VPC networking resources (these should be in infra-kubernetes)
echo "🗑️  Removing old VPC resources..."
OLD_VPC_RESOURCES=(
    "aws_vpc.main"
    "aws_subnet.public[0]"
    "aws_subnet.public[1]"
    "aws_subnet.private[0]"
    "aws_subnet.private[1]"
    "aws_route_table.public"
    "aws_route_table.private[0]"
    "aws_route_table.private[1]"
    "aws_internet_gateway.main"
    "aws_nat_gateway.main[0]"
    "aws_nat_gateway.main[1]"
    "aws_eip.nat[0]"
    "aws_eip.nat[1]"
    "aws_route_table_association.public[0]"
    "aws_route_table_association.public[1]"
    "aws_route_table_association.private[0]"
    "aws_route_table_association.private[1]"
)

for resource in "${OLD_VPC_RESOURCES[@]}"; do
    if terraform state list | grep -q "^${resource}$"; then
        echo "Removing: $resource"
        terraform state rm "$resource" || echo "Failed to remove $resource (may not exist)"
    fi
done

# Remove ECR resources (these should be in infra-kubernetes)
echo "🗑️  Removing ECR resources..."
ECR_RESOURCES=(
    "aws_ecr_repository.pedidos_api"
)

for resource in "${ECR_RESOURCES[@]}"; do
    if terraform state list | grep -q "^${resource}$"; then
        echo "Removing: $resource"
        terraform state rm "$resource" || echo "Failed to remove $resource (may not exist)"
    fi
done

echo "✅ State cleanup completed!"
echo "📋 Remaining resources (should only be DB-related):"
terraform state list

echo ""
echo "🔍 Resources that SHOULD remain in infra-db:"
echo "  - aws_vpc.db_vpc"
echo "  - aws_subnet.db_public[*]"
echo "  - aws_internet_gateway.db_igw"
echo "  - aws_route_table.db_public"
echo "  - aws_route_table_association.db_public[*]"
echo "  - aws_db_subnet_group.main"
echo "  - aws_security_group.rds"
echo "  - aws_db_instance.postgres-v2"

echo ""
echo "🚀 Next steps:"
echo "1. Run: terraform plan"
echo "2. Verify only DB resources are shown"
echo "3. Run: terraform apply (if plan looks correct)"
echo "4. Proceed with infra-kubernetes project"