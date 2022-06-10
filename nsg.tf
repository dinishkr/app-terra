
resource "azurerm_network_security_group" "app_vmnic_nsg" {
  name                = "app-nsg"
  location            = data.azurerm_resource_group.rg-nw.location
  resource_group_name = data.azurerm_resource_group.rg-nw.name
}

# Resource-2: Associate NSG and Linux VM NIC
resource "azurerm_network_interface_security_group_association" "app_vmnic_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.app_vmnic_nsg_rule_inbound]
  for_each           =  toset(var.vm_name)
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.app_vmnic_nsg.id
}

# Resource-3: Create NSG Rules
## Locals Block for Security Rules
locals {
  web_vmnic_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "3389"
  } 
}
## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "app_vmnic_nsg_rule_inbound" {
  for_each = local.web_vmnic_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg-nw.name
  network_security_group_name = azurerm_network_security_group.app_vmnic_nsg.name
}
