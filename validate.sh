#!/bin/bash
# ==============================================================================
# validate.sh - NFS Quick Start Validation (Azure)
# ------------------------------------------------------------------------------
# Purpose:
#   - Queries Azure for expected NFS Gateway Quick Start resources and prints
#     quick-start endpoints for copy/paste access.
#
# Scope:
#   - Looks up Public IP DNS FQDNs created by Terraform:
#       - Windows admin host (management / test client): win-adminuser-<suffix>
#       - Linux NFS gateway host: nfs-gateway-<suffix>
#   - Optionally discovers the Key Vault name used for credentials/secrets.
#
# Fast-Fail Behavior:
#   - Script exits immediately on command failure, unset variables,
#     or failed pipelines.
#
# Requirements:
#   - Azure CLI installed and authenticated (az login).
#   - Resources deployed in the expected resource group.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
RESOURCE_GROUP="nfs-project-rg"

WIN_LABEL_PREFIX="win-adminuser-"
LINUX_LABEL_PREFIX="nfs-gateway-"

# Key Vault prefix for this NFS Gateway Quick Start (credentials/secrets storage).
KEYVAULT_PREFIX="nfs-key-vault"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
az_trim() {
  # Trims whitespace/newlines from az output.
  xargs 2>/dev/null || true
}

get_public_fqdn_by_domain_label_prefix() {
  local rg="$1"
  local prefix="$2"

  az network public-ip list \
    --resource-group "${rg}" \
    --query "[?dnsSettings && starts_with(dnsSettings.domainNameLabel, '${prefix}')].dnsSettings.fqdn | [0]" \
    --output tsv | az_trim
}

get_key_vault_by_prefix() {
  local rg="$1"
  local prefix="$2"

  az keyvault list \
    --resource-group "${rg}" \
    --query "[?starts_with(name, '${prefix}')].name | [0]" \
    --output tsv | az_trim
}

# ------------------------------------------------------------------------------
# Lookups
# ------------------------------------------------------------------------------
windows_fqdn="$(get_public_fqdn_by_domain_label_prefix "${RESOURCE_GROUP}" "${WIN_LABEL_PREFIX}")"
linux_fqdn="$(get_public_fqdn_by_domain_label_prefix "${RESOURCE_GROUP}" "${LINUX_LABEL_PREFIX}")"
vault_name="$(get_key_vault_by_prefix "${RESOURCE_GROUP}" "${KEYVAULT_PREFIX}")"

# ------------------------------------------------------------------------------
# Quick Start Output
# ------------------------------------------------------------------------------
echo ""
echo "============================================================================"
echo "NFS Quick Start - Validation Output (Azure)"
echo "============================================================================"
echo ""

printf "%-28s %s\n" "NOTE: Resource Group:" "${RESOURCE_GROUP}"
printf "%-28s %s\n" "NOTE: Key Vault:"      "${vault_name}"

echo ""

printf "%-28s %s\n" "NOTE: Windows RDP Host:" "${windows_fqdn}"
printf "%-28s %s\n" "NOTE: NFS Gateway Host:" "${linux_fqdn}"

echo ""

