#!/bin/bash
set -e

echo "Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y curl unzip

# Install Terraform (Direct Binary)
TERRAFORM_VERSION="1.9.0"
echo "Installing Terraform v${TERRAFORM_VERSION}..."
curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
echo "Terraform installed successfully!"

# Install AWS CLI (Direct Bundle)
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
rm awscliv2.zip
rm -rf aws
echo "AWS CLI installed successfully!"

echo "Verifying installations..."
terraform -version
aws --version

echo "Setup complete! Please run 'aws configure' next."
