resource "azurerm_network_interface" "nic" {
  for_each   = toset(var.vm_name)  
  name                = "${each.key}-nic"
  location            = data.azurerm_resource_group.rg-nw.location
  resource_group_name = data.azurerm_resource_group.rg-nw.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.appsubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags["owner"],
    ]
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = toset(var.vm_name) 
  #for_each = azurerm_network_interface.nic  
  name                = each.value
  resource_group_name = data.azurerm_resource_group.rg-app.name
  location            = data.azurerm_resource_group.rg-app.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]
  license_type = "Windows_Server"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
 #   disk_encryption_set_id = "/subscriptions/7f60296c-ffff-46d1-b231-c71f26606fd8/resourceGroups/network-rg/providers/Microsoft.Compute/diskEncryptionSets/vm-encryption"
     disk_encryption_set_id = data.azurerm_disk_encryption_set.disk-encrypt.id
  }

  boot_diagnostics {
    storage_account_uri = "https://bootdiag54.blob.core.windows.net/"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  #boot_diagnostics {
   #  enabled = "true" 
   #  storage_uri = data.azurem_storage_account.diagstorage.primary_blob_endpoint
  #}


  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags["owner"],
    ]
  }
}

resource "azurerm_managed_disk" "disk" {
   for_each            = toset(var.vm_name)  
  name                 = "${each.value}-disk1"
 # name                 = azurerm_windows_virtual_machine.vm[each.key].name  
  location             = data.azurerm_resource_group.rg-app.location
  resource_group_name  = data.azurerm_resource_group.rg-app.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
  disk_encryption_set_id = data.azurerm_disk_encryption_set.disk-encrypt.id
  depends_on = [
    azurerm_windows_virtual_machine.vm
  ]
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags["owner"],
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  for_each           =  toset(var.vm_name)   
  managed_disk_id    =  azurerm_managed_disk.disk[each.key].id
  virtual_machine_id =  azurerm_windows_virtual_machine.vm[each.key].id
  lun                =  "10"
  caching            =  "ReadWrite"
  depends_on = [
    azurerm_managed_disk.disk
  ]
 
}