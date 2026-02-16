# ==============================================================================
# Azure Provider and Core Data Sources
# ------------------------------------------------------------------------------
# Configures AzureRM provider and key data sources.
# Defines resource group and Key Vault inputs.
# Loads subscription, client, RG, VNet, subnet, and Key Vault details.
# ==============================================================================


# ------------------------------------------------------------------------------
# AzureRM Provider Configuration
# ------------------------------------------------------------------------------
provider "azurerm" {

  features {

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
  }
}


# ------------------------------------------------------------------------------
# Data Sources: Subscription and Client Context
# ------------------------------------------------------------------------------
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "resource_group_name" {

  description = "Azure resource group name."
  type        = string
  default     = "nfs-project-rg"
}

variable "vault_name" {

  description = "Name of the Key Vault for secrets."
  type        = string
}


# ------------------------------------------------------------------------------
# Data Source: Resource Group
# ------------------------------------------------------------------------------
data "azurerm_resource_group" "ad" {

  name = var.resource_group_name
}


# ------------------------------------------------------------------------------
# Data Source: Virtual Network
# ------------------------------------------------------------------------------
data "azurerm_virtual_network" "ad_vnet" {

  name                = "ad-vnet"
  resource_group_name = data.azurerm_resource_group.ad.name
}


# ------------------------------------------------------------------------------
# Data Source: VM Subnet
# ------------------------------------------------------------------------------
data "azurerm_subnet" "vm_subnet" {

  name                 = "vm-subnet"
  resource_group_name  = data.azurerm_resource_group.ad.name
  virtual_network_name = data.azurerm_virtual_network.ad_vnet.name
}


# ------------------------------------------------------------------------------
# Data Source: Key Vault
# ------------------------------------------------------------------------------
data "azurerm_key_vault" "ad_key_vault" {

  name                = var.vault_name
  resource_group_name = var.resource_group_name
}
