# ==============================================================================
# Storage Account: Deployment Scripts
# ------------------------------------------------------------------------------
# Creates storage account and private container for scripts.
# Renders AD join PowerShell script from template.
# Uploads rendered script and generates short-lived SAS token.
# ==============================================================================


# ------------------------------------------------------------------------------
# Random String: Storage Account Name Suffix
# ------------------------------------------------------------------------------
# Ensures global uniqueness for storage account name.
# ------------------------------------------------------------------------------
resource "random_string" "storage_name" {

  length  = 10
  upper   = false
  special = false
  numeric = true
}


# ------------------------------------------------------------------------------
# Storage Account: Scripts
# ------------------------------------------------------------------------------
# Hosts deployment scripts as private blobs.
# ------------------------------------------------------------------------------
resource "azurerm_storage_account" "scripts_storage" {

  name                     = "vmscripts${random_string.storage_name.result}"
  resource_group_name      = data.azurerm_resource_group.ad.name
  location                 = data.azurerm_resource_group.ad.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# ------------------------------------------------------------------------------
# Storage Container: scripts
# ------------------------------------------------------------------------------
# Private container for deployment scripts.
# ------------------------------------------------------------------------------
resource "azurerm_storage_container" "scripts" {

  name                  = "scripts"
  storage_account_id    = azurerm_storage_account.scripts_storage.id
  container_access_type = "private"
}


# ------------------------------------------------------------------------------
# Local: Render AD Join Script
# ------------------------------------------------------------------------------
# Injects Key Vault, domain, and gateway IP values into script template.
# ------------------------------------------------------------------------------
locals {

  ad_join_script = templatefile("./scripts/ad_join.ps1.template", {
    vault_name  = data.azurerm_key_vault.ad_key_vault.name
    domain_fqdn = "mcloud.mikecloud.com"
    nfs_gateway = azurerm_network_interface.nfs_gateway_nic.ip_configuration[0].private_ip_address
  })
}


# ------------------------------------------------------------------------------
# Local File: Rendered Script
# ------------------------------------------------------------------------------
# Writes rendered script to local filesystem for upload.
# ------------------------------------------------------------------------------
resource "local_file" "ad_join_rendered" {

  filename = "./scripts/ad_join.ps1"
  content  = local.ad_join_script
}


# ------------------------------------------------------------------------------
# Storage Blob: Upload Script
# ------------------------------------------------------------------------------
# Uploads rendered script into private scripts container.
# ------------------------------------------------------------------------------
resource "azurerm_storage_blob" "ad_join_script" {

  name                   = "ad-join.ps1"
  storage_account_name   = azurerm_storage_account.scripts_storage.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = local_file.ad_join_rendered.filename

  metadata = {
    force_update = timestamp()
  }
}


# ------------------------------------------------------------------------------
# SAS Token: Script Access
# ------------------------------------------------------------------------------
# Generates read-only SAS token for script download.
# Validity: starts 24h ago and expires 72h from now.
# ------------------------------------------------------------------------------
data "azurerm_storage_account_sas" "script_sas" {

  connection_string = azurerm_storage_account.scripts_storage.primary_connection_string

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timeadd(timestamp(), "-24h"))
  expiry = formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timeadd(timestamp(), "72h"))

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    filter  = false
    tag     = false
  }
}
