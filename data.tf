data "azurerm_resource_group" "rg-app" {
  name = "fab-test"
}

data "azurerm_resource_group" "rg-nw" {
  name = "network-rg"
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet2"
  resource_group_name = data.azurerm_resource_group.rg-nw.name
}

data "azurerm_subnet" "appsubnet" {
  name                 = "appsubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg-nw.name
}

data "azurerm_disk_encryption_set" "disk-encrypt" {
      name  = "vm-encryption"
      resource_group_name = data.azurerm_resource_group.rg-nw.name
}

data "azurerm_storage_account" "diagstorage" {
      name =  "bootdiag54"
      resource_group_name = data.azurerm_resource_group.rg-nw.name
}