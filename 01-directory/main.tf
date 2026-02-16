# ==============================================================================
# AzureRM Provider and Core Resource Group Setup
# ------------------------------------------------------------------------------
# Purpose:
#   - Configure AzureRM provider features
#   - Retrieve subscription and client identity details
#   - Define input variables for Resource Group
#   - Create primary Resource Group for deployment
# ==============================================================================


# ------------------------------------------------------------------------------
# AzureRM Provider Configuration
# ------------------------------------------------------------------------------

provider "azurerm" {

  features {

    # Key Vault feature configuration
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }

    # Resource Group feature configuration
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

# Fetch subscription details
data "azurerm_subscription" "primary" {}

# Fetch authenticated client configuration
data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------------------

resource "azurerm_resource_group" "ad" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
