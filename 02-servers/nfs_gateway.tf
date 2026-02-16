# ==============================================================================
# Linux VM Deployment: NFS Gateway
# ------------------------------------------------------------------------------
# Provisions Ubuntu-based NFS gateway VM.
# Generates ubuntu credentials and stores them in Key Vault.
# Creates public IP with DNS label matching VM name.
# Creates NIC and assigns Key Vault read permissions to VM identity.
# ==============================================================================


# ------------------------------------------------------------------------------
# Random Password: ubuntu
# ------------------------------------------------------------------------------
# Generates secure password for ubuntu account.
# ------------------------------------------------------------------------------
resource "random_password" "ubuntu_password" {

  length           = 24
  special          = true
  override_special = "!@#$%"
}


# ------------------------------------------------------------------------------
# Key Vault Secret: ubuntu credentials
# ------------------------------------------------------------------------------
# Stores ubuntu username/password as JSON object.
# ------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "ubuntu_secret" {

  name = "ubuntu-credentials"

  value = jsonencode({
    username = "ubuntu"
    password = random_password.ubuntu_password.result
  })

  key_vault_id = data.azurerm_key_vault.ad_key_vault.id
  content_type = "application/json"
}


# ------------------------------------------------------------------------------
# Public IP: NFS Gateway
# ------------------------------------------------------------------------------
# Creates static public IP.
# DNS label matches VM name.
# ------------------------------------------------------------------------------
resource "azurerm_public_ip" "nfs_gateway_pip" {

  name                = "nfs-gateway-pip"
  location            = data.azurerm_resource_group.ad.location
  resource_group_name = data.azurerm_resource_group.ad.name

  allocation_method = "Static"
  sku               = "Standard"

  domain_name_label = "nfs-gateway-${random_string.vm_suffix.result}"
}


# ------------------------------------------------------------------------------
# Network Interface: NFS Gateway
# ------------------------------------------------------------------------------
# Creates NIC in VM subnet for NFS gateway VM.
# Associates public IP for internet access.
# ------------------------------------------------------------------------------
resource "azurerm_network_interface" "nfs_gateway_nic" {

  name                = "nfs-gateway-nic"
  location            = data.azurerm_resource_group.ad.location
  resource_group_name = data.azurerm_resource_group.ad.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.nfs_gateway_pip.id
  }
}


# ------------------------------------------------------------------------------
# Linux Virtual Machine: NFS Gateway
# ------------------------------------------------------------------------------
# Deploys Ubuntu 24.04 LTS VM and injects cloud-init via custom_data.
# ------------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "nfs_gateway" {

  name = "nfs-gateway-${random_string.vm_suffix.result}"

  location            = data.azurerm_resource_group.ad.location
  resource_group_name = data.azurerm_resource_group.ad.name
  size                = "Standard_B1s"

  admin_username                  = "ubuntu"
  admin_password                  = random_password.ubuntu_password.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nfs_gateway_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Cloud-init bootstrap
  custom_data = base64encode(templatefile(
    "./scripts/custom_data.sh",
    {
      vault_name      = data.azurerm_key_vault.ad_key_vault.name
      domain_fqdn     = var.dns_zone
      netbios         = var.netbios
      force_group     = "mcloud-users"
      realm           = var.realm
      storage_account = azurerm_storage_account.nfs_storage_account.name
    }
  ))

  identity {
    type = "SystemAssigned"
  }
}


# ------------------------------------------------------------------------------
# RBAC: VM Managed Identity Access to Key Vault
# ------------------------------------------------------------------------------
# Grants VM permission to read secrets from Key Vault.
# ------------------------------------------------------------------------------
resource "azurerm_role_assignment" "vm_lnx_key_vault_secrets_user" {

  scope                = data.azurerm_key_vault.ad_key_vault.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_linux_virtual_machine.nfs_gateway.identity[0].principal_id
}
