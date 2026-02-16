# ==================================================================================================
# AzureRM Provider and Core Resource Group Setup
# - Configures Azure provider features
# - Defines subscription and client data sources
# - Declares input variables for RG name and location
# - Creates the primary resource group for deployment
# ==================================================================================================

# --------------------------------------------------------------------------------------------------
# Configure AzureRM provider
# --------------------------------------------------------------------------------------------------
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true   # Purge Key Vault immediately on destroy
      recover_soft_deleted_key_vaults = false  # Do not auto-recover deleted Key Vaults
    }

    resource_group {
      prevent_deletion_if_contains_resources = false # Allow deletion of RG even if non-empty
    }
  }
}

# --------------------------------------------------------------------------------------------------
# Fetch subscription details (subscription ID, display name, etc.)
# --------------------------------------------------------------------------------------------------
data "azurerm_subscription" "primary" {}

# --------------------------------------------------------------------------------------------------
# Fetch details of the authenticated client (SPN or user identity)
# --------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# --------------------------------------------------------------------------------------------------
# Input variable: Resource Group name
# --------------------------------------------------------------------------------------------------
variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "nfs-project-rg"
}

# --------------------------------------------------------------------------------------------------
# Input variable: Resource Group location
# --------------------------------------------------------------------------------------------------
variable "resource_group_location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "Central US"
}

# --------------------------------------------------------------------------------------------------
# Create the Resource Group
# --------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "ad" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
# ==============================================================================
# Azure Provider Configuration
# ------------------------------------------------------------------------------
# Configures AzureRM provider and feature behavior.
# Enables Key Vault purge and allows RG deletion with resources.
# ==============================================================================

provider "azurerm" {

  features {

    # Key Vault feature configuration.
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }

    # Resource group feature configuration.
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


# ==============================================================================
# Data Sources
# ------------------------------------------------------------------------------
# Retrieves subscription and current client configuration details.
# ==============================================================================

data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}


# ==============================================================================
# Variables
# ------------------------------------------------------------------------------
# Defines resource group name and deployment region.
# ==============================================================================

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "nfs-project-rg"
}

variable "resource_group_location" {
  description = "Azure region for resource group."
  type        = string
  default     = "Central US"
}


# ==============================================================================
# Resource Group
# ------------------------------------------------------------------------------
# Creates resource group to contain all AD-related resources.
# ==============================================================================

resource "azurerm_resource_group" "ad" {

  name     = var.resource_group_name
  location = var.resource_group_location
}