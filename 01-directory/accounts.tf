# ==============================================================================
# User Credential Management
# ------------------------------------------------------------------------------
# Generates strong random passwords for AD users.
# Stores credentials in Azure Key Vault as JSON objects.
#
# Notes:
#   - Each user receives a unique 24-character password.
#   - Special characters restricted for AD/script compatibility.
#   - Secrets depend on Key Vault role assignment.
# ==============================================================================


# ------------------------------------------------------------------------------
# User: John Smith (jsmith)
# ------------------------------------------------------------------------------
resource "random_password" "jsmith_password" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "azurerm_key_vault_secret" "jsmith_secret" {
  name = "jsmith-ad-credentials"
  value = jsonencode({
    username = "jsmith@${var.dns_zone}"
    password = random_password.jsmith_password.result
  })
  key_vault_id = azurerm_key_vault.ad_key_vault.id
  depends_on   = [azurerm_role_assignment.kv_role_assignment]
  content_type = "application/json"
}


# ------------------------------------------------------------------------------
# User: Emily Davis (edavis)
# ------------------------------------------------------------------------------
resource "random_password" "edavis_password" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "azurerm_key_vault_secret" "edavis_secret" {
  name = "edavis-ad-credentials"
  value = jsonencode({
    username = "edavis@${var.dns_zone}"
    password = random_password.edavis_password.result
  })
  key_vault_id = azurerm_key_vault.ad_key_vault.id
  depends_on   = [azurerm_role_assignment.kv_role_assignment]
  content_type = "application/json"
}


# ------------------------------------------------------------------------------
# User: Raj Patel (rpatel)
# ------------------------------------------------------------------------------
resource "random_password" "rpatel_password" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "azurerm_key_vault_secret" "rpatel_secret" {
  name = "rpatel-ad-credentials"
  value = jsonencode({
    username = "rpatel@${var.dns_zone}"
    password = random_password.rpatel_password.result
  })
  key_vault_id = azurerm_key_vault.ad_key_vault.id
  depends_on   = [azurerm_role_assignment.kv_role_assignment]
  content_type = "application/json"
}


# ------------------------------------------------------------------------------
# User: Amit Kumar (akumar)
# ------------------------------------------------------------------------------
resource "random_password" "akumar_password" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "azurerm_key_vault_secret" "akumar_secret" {
  name = "akumar-ad-credentials"
  value = jsonencode({
    username = "akumar@${var.dns_zone}"
    password = random_password.akumar_password.result
  })
  key_vault_id = azurerm_key_vault.ad_key_vault.id
  depends_on   = [azurerm_role_assignment.kv_role_assignment]
  content_type = "application/json"
}


# ------------------------------------------------------------------------------
# User: sysadmin (Local Service Account)
# ------------------------------------------------------------------------------
resource "random_password" "sysadmin_password" {
  length           = 24
  special          = true
  override_special = "!@#%"
}

resource "azurerm_key_vault_secret" "sysadmin_secret" {
  name = "sysadmin-credentials"
  value = jsonencode({
    username = "sysadmin"
    password = random_password.sysadmin_password.result
  })
  key_vault_id = azurerm_key_vault.ad_key_vault.id
  depends_on   = [azurerm_role_assignment.kv_role_assignment]
  content_type = "application/json"
}


# ------------------------------------------------------------------------------
# User: Admin (Domain Administrator)
# ------------------------------------------------------------------------------
resource "random_password" "admin_password" {
  length           = 24
  special          = true
  override_special = "-_"
}

resource "azurerm_key_vault_secret" "admin_secret" {
  name = "admin-ad-credentials"
  value = jsonencode({
    username = "Admin@${var.dns_zone}"
    password = random_password.admin_password.result
  })
  key_vault_id = azurerm_key_vault.ad_key_vault.id
  depends_on   = [azurerm_role_assignment.kv_role_assignment]
  content_type = "application/json"
}