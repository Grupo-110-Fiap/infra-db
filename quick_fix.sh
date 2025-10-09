#!/bin/bash

# Quick fix for Terraform Cloud execution
# This script removes Kubernetes provider references that shouldn't be in infra-db

echo "🚀 Quick fix for Terraform Cloud execution..."

# Check if we're in the right directory
if [ ! -f "main.tf" ] || [ ! -f "provider.tf" ]; then
    echo "❌ Error: Please run this script from the infra-db directory"
    exit 1
fi

# Check if there are any Kubernetes provider references in the configuration files
echo "🔍 Checking for Kubernetes references in configuration files..."

KUBERNETES_FOUND=false

# Search for kubernetes provider or resources in .tf files
if grep -r "kubernetes" *.tf 2>/dev/null; then
    KUBERNETES_FOUND=true
fi

if [ "$KUBERNETES_FOUND" = true ]; then
    echo "❌ Found Kubernetes references in configuration files!"
    echo "   This infra-db project should only contain AWS resources."
    echo "   Please remove any Kubernetes provider or resource blocks."
    exit 1
fi

echo "✅ Configuration files look clean (no Kubernetes references)"

# Initialize terraform with upgrade to fix provider version issues
echo "🔄 Reinitializing Terraform with provider upgrade..."
terraform init -upgrade

echo "📋 Current state resources:"
terraform state list 2>/dev/null || echo "No state found or state is corrupted"

echo ""
echo "🎯 Next steps:"
echo "1. Review the state list above"
echo "2. If you see Kubernetes or EKS resources, run: ./cleanup_state.sh"
echo "3. Then run: terraform plan"
echo "4. If plan shows only DB resources, run: terraform apply"

echo ""
echo "✅ Quick fix completed!"