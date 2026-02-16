#!/bin/bash
# ==============================================================================
# NFS Gateway Deployment Script (Azure)
# ------------------------------------------------------------------------------
# Deploys NFS gateway infrastructure in two phases:
#   1. Directory layer (Key Vault and shared dependencies).
#   2. Server layer (Linux NFS gateway VM).
#
# Purpose:
#   - Provision Linux server acting as NFS gateway.
#   - Retrieve Key Vault name from Phase 1.
#   - Pass vault name into server Terraform module.
#
# Requirements:
#   - Azure CLI authenticated.
#   - Terraform installed.
#   - check_env.sh available.
# ==============================================================================

set -e


# ------------------------------------------------------------------------------
# Pre-Flight Validation
# ------------------------------------------------------------------------------
# Ensure Azure CLI, Terraform, and required environment are ready.
# ------------------------------------------------------------------------------
./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi


# ------------------------------------------------------------------------------
# Phase 1: Directory Layer
# ------------------------------------------------------------------------------
# Deploy Key Vault and base infrastructure required by NFS gateway.
# ------------------------------------------------------------------------------
cd 01-directory

terraform init
terraform apply -auto-approve

if [ $? -ne 0 ]; then
  echo "ERROR: Terraform apply failed in 01-directory."
  exit 1
fi

cd ..


# ------------------------------------------------------------------------------
# Phase 2: NFS Gateway Server
# ------------------------------------------------------------------------------
# Deploy Linux VM configured as NFS gateway.
# Discover Key Vault name and pass to Terraform.
# ------------------------------------------------------------------------------
cd 02-servers

vault=$(az keyvault list \
  --resource-group nfs-project-rg \
  --query "[?starts_with(name, 'ad-key-vault')].name | [0]" \
  --output tsv)

echo "NOTE: Key vault for secrets is $vault"

terraform init
terraform apply -var="vault_name=$vault" -auto-approve

cd ..
