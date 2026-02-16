# ==============================================================================
# Mini Active Directory Module Invocation
# ------------------------------------------------------------------------------
# Calls reusable mini-ad module to deploy Ubuntu-based AD controller.
# Passes networking, DNS, authentication, and user parameters.
# ==============================================================================

module "mini_ad" {

  source   = "github.com/mamonaco1973/module-azure-mini-ad"
  location = var.resource_group_location
  netbios  = var.netbios
  vnet_id  = azurerm_virtual_network.ad_vnet.id
  realm    = var.realm

  # JSON blob containing user definitions.
  users_json = local.users_json

  user_base_dn      = var.user_base_dn
  ad_admin_password = random_password.admin_password.result
  dns_zone          = var.dns_zone
  subnet_id         = azurerm_subnet.mini_ad_subnet.id
  admin_password    = random_password.sysadmin_password.result

  # Ensure NAT and subnet association exist before AD deployment.
  depends_on = [
    azurerm_nat_gateway.vm_nat_gateway,
    azurerm_subnet_nat_gateway_association.mini_ad_nat_assoc
  ]
}


# ==============================================================================
# Local Variable: users_json
# ------------------------------------------------------------------------------
# Renders users.json.template into JSON string.
# Injects randomized passwords for demo/test users.
# Passed to VM bootstrap for automatic account creation.
# ==============================================================================

locals {

  users_json = templatefile(
    "./scripts/users.json.template",
    {
      USER_BASE_DN = var.user_base_dn
      DNS_ZONE     = var.dns_zone
      REALM        = var.realm
      NETBIOS      = var.netbios

      jsmith_password = random_password.jsmith_password.result
      edavis_password = random_password.edavis_password.result
      rpatel_password = random_password.rpatel_password.result
      akumar_password = random_password.akumar_password.result
    }
  )
}