# ==============================================================================
# Active Directory Naming Inputs
# ------------------------------------------------------------------------------
# Defines DNS, Kerberos, and NetBIOS identifiers for the AD domain.
# Used by Samba AD DC and Kerberos configuration.
# ==============================================================================


# ------------------------------------------------------------------------------
# DNS Zone (FQDN)
# ------------------------------------------------------------------------------
# Fully qualified domain name for the AD domain.
# Used for DNS namespace and domain identity.
# ------------------------------------------------------------------------------
variable "dns_zone" {

  description = "AD DNS zone (e.g., mcloud.mikecloud.com)."
  type        = string
  default     = "mcloud.mikecloud.com"
}


# ------------------------------------------------------------------------------
# Kerberos Realm (Uppercase)
# ------------------------------------------------------------------------------
# Convention: matches dns_zone but in uppercase.
# Required for Kerberos authentication configuration.
# ------------------------------------------------------------------------------
variable "realm" {

  description = "Kerberos realm (e.g., MCLOUD.MIKECLOUD.COM)."
  type        = string
  default     = "MCLOUD.MIKECLOUD.COM"
}


# ------------------------------------------------------------------------------
# NetBIOS Short Domain Name
# ------------------------------------------------------------------------------
# Short domain identifier (<= 15 characters).
# Used by legacy systems and SMB authentication flows.
# ------------------------------------------------------------------------------
variable "netbios" {

  description = "NetBIOS short name (e.g., MCLOUD)."
  type        = string
  default     = "MCLOUD"
}
