# ==============================================================================
# Virtual Network
# ------------------------------------------------------------------------------
# Defines primary VNet for AD and supporting infrastructure.
# ==============================================================================

resource "azurerm_virtual_network" "ad_vnet" {

  name                = "ad-vnet"
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.ad.location
  resource_group_name = azurerm_resource_group.ad.name
}


# ==============================================================================
# Subnets
# ------------------------------------------------------------------------------
# Creates subnets for VMs, Mini-AD, and Bastion.
# ==============================================================================

resource "azurerm_subnet" "vm_subnet" {

  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.ad.name
  virtual_network_name = azurerm_virtual_network.ad_vnet.name
  address_prefixes     = ["10.0.0.0/25"]

  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "mini_ad_subnet" {

  name                 = "mini-ad-subnet"
  resource_group_name  = azurerm_resource_group.ad.name
  virtual_network_name = azurerm_virtual_network.ad_vnet.name
  address_prefixes     = ["10.0.0.128/25"]

  default_outbound_access_enabled = false
}

# ==============================================================================
# VM Network Security Group
# ------------------------------------------------------------------------------
# Allows SSH and RDP inbound to VM subnet.
# ==============================================================================

resource "azurerm_network_security_group" "vm_nsg" {

  name                = "vm-nsg"
  location            = azurerm_resource_group.ad.location
  resource_group_name = azurerm_resource_group.ad.name

  # Inbound SSH
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Inbound RDP
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# ==============================================================================
# NSG Association
# ------------------------------------------------------------------------------
# Associates VM subnet with VM NSG.
# ==============================================================================

resource "azurerm_subnet_network_security_group_association" "vm-nsg-assoc" {

  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}


# ==============================================================================
# NAT Gateway Configuration
# ------------------------------------------------------------------------------
# Provides outbound internet access for private subnets.
# ==============================================================================

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_gateway_pip" {

  name                = "nat-gateway-pip"
  location            = azurerm_resource_group.ad.location
  resource_group_name = azurerm_resource_group.ad.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway resource
resource "azurerm_nat_gateway" "vm_nat_gateway" {

  name                    = "vm-nat-gateway"
  location                = azurerm_resource_group.ad.location
  resource_group_name     = azurerm_resource_group.ad.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

# Associate public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gw_pip_assoc" {

  nat_gateway_id       = azurerm_nat_gateway.vm_nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_pip.id
}

# Associate NAT with VM subnet
resource "azurerm_subnet_nat_gateway_association" "vm_nat_assoc" {

  subnet_id      = azurerm_subnet.vm_subnet.id
  nat_gateway_id = azurerm_nat_gateway.vm_nat_gateway.id
}

# Associate NAT with Mini-AD subnet
resource "azurerm_subnet_nat_gateway_association" "mini_ad_nat_assoc" {

  subnet_id      = azurerm_subnet.mini_ad_subnet.id
  nat_gateway_id = azurerm_nat_gateway.vm_nat_gateway.id
}