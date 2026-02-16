# ==============================================================================
# Active Directory Naming Inputs
# ------------------------------------------------------------------------------
# Defines DNS, Kerberos, and NetBIOS naming for AD domain.
# ==============================================================================


# ------------------------------------------------------------------------------
# DNS Zone (FQDN)
# ------------------------------------------------------------------------------
# Fully qualified AD domain name.
# Used by Samba AD DC for DNS namespace and identity.
# ------------------------------------------------------------------------------
variable "dns_zone" {

  description = "AD DNS zone (e.g., mcloud.mikecloud.com)."
  type        = string
  default     = "mcloud.mikecloud.com"
}


# ------------------------------------------------------------------------------
# Kerberos Realm (Uppercase)
# ------------------------------------------------------------------------------
# Convention: match dns_zone in uppercase.
# Required for Kerberos authentication configuration.
# ------------------------------------------------------------------------------
variable "realm" {

  description = "Kerberos realm (e.g., MCLOUD.MIKECLOUD.COM)."

  type    = string
  default = "MCLOUD.MIKECLOUD.COM"
}


# ------------------------------------------------------------------------------
# NetBIOS Domain Name
# ------------------------------------------------------------------------------
# Short domain name (<= 15 chars).
# Used by legacy systems and SMB workflows.
# ------------------------------------------------------------------------------
variable "netbios" {

  description = "NetBIOS short name (e.g., MCLOUD)."
  type        = string
  default     = "MCLOUD"
}


# ------------------------------------------------------------------------------
# LDAP User Base DN
# ------------------------------------------------------------------------------
# Distinguished Name used as base for AD user accounts.
# ------------------------------------------------------------------------------
variable "user_base_dn" {

  description = "LDAP user base DN (e.g., CN=Users,DC=mcloud,DC=mikecloud,DC=com)."

  type    = string
  default = "CN=Users,DC=mcloud,DC=mikecloud,DC=com"
}

# ============================================================================== 
# Variable: bastion_support
# ------------------------------------------------------------------------------
# Purpose:
#   Controls whether Azure Bastion infrastructure is deployed.
#
# Behavior:
#   - true  : Deploy Bastion subnet, NSG, public IP, and Bastion host.
#   - false : Skip Bastion-related resources entirely.
#
# Notes:
#   - Default is false to avoid unnecessary cost.
#   - When enabled, dependent resources must use count or for_each logic.
# ==============================================================================

variable "bastion_support" {
  description = "Deploy Azure Bastion resources"
  type        = bool
  default     = true
}