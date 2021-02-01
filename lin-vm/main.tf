#######################################
## Windows VM          Server - Main ##
#######################################

# Get a Static Public IP 
# resource "azurerm_public_ip" "lin-vm-ip" {
#  name                = "pub-ip-${var.vm_name}-${var.project_id}-${var.environment}"
#  location            = var.vm_location
#  resource_group_name = var.vm_rg_name
#  allocation_method   = "Static"
#  
#  tags = { 
#    environment = var.environment 
#    BackLogItem = var.BackLogItem
#  }
#}

# Create Network Card for web VM buyusa
resource "azurerm_network_interface" "lin-vm-nic" {
  
  name                      = "${var.vm_name}-vm-nic-${var.project_id}-${var.environment}"
  location                  = var.vm_location
  resource_group_name       = var.vm_rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.lin-vm-ip.id
  }

  tags = { 
    #application = var.app_name
    environment = var.environment
    BackLogItem = var.BackLogItem 
  }
}

# Create Linux Server
resource "azurerm_linux_virtual_machine" "lin-vm" {
  depends_on=[azurerm_network_interface.lin-vm-nic]

  name                  = "vm-${var.vm_name}-${var.project_id}-${var.environment}"
  location              = var.vm_location
  resource_group_name   = var.vm_rg_name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.lin-vm-nic.id]

  admin_username        = var.admin_username
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "vm-os-disk-${var.vm_name}-${var.project_id}-${var.environment}"
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  provision_vm_agent       = true

  tags = {
    #application = var.app_name
    environment = var.environment
    BackLogItem = var.BackLogItem 
  }
}


resource "azurerm_managed_disk" "data_disk" {
  name                 = "vm-data-disk_01-${var.vm_name}-${var.project_id}-${var.environment}"
  location             = var.vm_location
  resource_group_name  = var.vm_rg_name
  storage_account_type = var.vm_storage_type
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach_disk_01" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.lin-vm.id
  lun                = "1"
  caching            = "ReadWrite"
}



resource "azurerm_network_interface_security_group_association" "vm-nsg-association" {
  network_interface_id      = azurerm_network_interface.lin-vm-nic.id
  network_security_group_id = var.network_security_group_id
}
