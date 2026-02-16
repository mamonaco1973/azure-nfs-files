# ==============================================================================
# Azure Key Vault Configuration
# ------------------------------------------------------------------------------
# Creates Key Vault for AD credentials and assigns RBAC permissions.
#
# Notes:
#   - purge_protection_enabled = false for lab use only.
#   - RBAC authorization enabled (no legacy access policies).
# ==============================================================================


# ------------------------------------------------------------------------------
# Random Suffix for Key Vault Name
# ------------------------------------------------------------------------------
# Ensures global uniqueness of Key Vault name.
# ------------------------------------------------------------------------------
resource "random_string" "key_vault_suffix" {

  length  = 8
  special = false
  upper   = false
}


# ------------------------------------------------------------------------------
# Azure Key Vault Resource
# ------------------------------------------------------------------------------
# Stores AD user and admin credentials securely.
# ------------------------------------------------------------------------------
resource "azurerm_key_vault" "ad_key_vault" {

  name = "ad-key-vault-${random_string.key_vault_suffix.result}"

  resource_group_name = azurerm_resource_group.ad.name
  location            = azurerm_resource_group.ad.location

  sku_name  = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id

  purge_protection_enabled   = false
  rbac_authorization_enabled = true
}


# ------------------------------------------------------------------------------
# RBAC Role Assignment
# ------------------------------------------------------------------------------
# Grants current Terraform identity permission to manage secrets.
# Role: Key Vault Secrets Officer.
# ------------------------------------------------------------------------------
resource "azurerm_role_assignment" "kv_role_assignment" {

  scope                = azurerm_key_vault.ad_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}