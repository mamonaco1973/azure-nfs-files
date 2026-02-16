#!/bin/bash
# ==============================================================================
# Mini Active Directory Destroy Script (Azure)
# ------------------------------------------------------------------------------
# Tears down infrastructure in reverse deployment order:
#   1. Server layer (VM, networking, role assignments).
#   2. Directory layer (Key Vault and base resources).
#
# WARNING:
#   - Permanently deletes all deployed resources.
#   - Requires Azure CLI and Terraform installed and authenticated.
# ==============================================================================

set -e


# ------------------------------------------------------------------------------
# Phase 1: Destroy Server Layer
# ------------------------------------------------------------------------------
# Removes AD VM and dependent resources.
# Discovers Key Vault name for Terraform input variable.
# ------------------------------------------------------------------------------
cd 02-servers

vault=$(az keyvault list \
  --resource-group nfs-project-rg \
  --query "[?starts_with(name, 'ad-key-vault')].name | [0]" \
  --output tsv)

echo "NOTE: Key vault for secrets is $vault"

terraform init
terraform destroy -var="vault_name=$vault" -auto-approve

cd ..


# ------------------------------------------------------------------------------
# Phase 2: Destroy Directory Layer
# ------------------------------------------------------------------------------
# Removes Key Vault and foundational infrastructure.
# Must run after server layer is destroyed.
# ------------------------------------------------------------------------------
cd 01-directory

terraform init
terraform destroy -auto-approve

cd ..
