
# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {}
}


/* -----------------------------------------------------------------------
-
Make RG in East US2 for VMs
-
*/

resource "azurerm_resource_group" "resource-group-left" {
  name     = "rgp-eastus2-${var.project_id}-${var.environment}"
  location = "East US2"
}

resource "azurerm_virtual_network" "vnet_left" {

  name                = "vnet-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-left.location
  resource_group_name = azurerm_resource_group.resource-group-left.name 

  address_space       = ["10.9.0.0/16"]

  tags = {
   # application = var.app_name
    environment = var.environment 
    BackLogItem = var.BackLogItem
  }

}

resource "azurerm_subnet" "def-subnet-left" {

  name                 = "sub-8-${var.project_id}-${var.environment}"
  resource_group_name  = azurerm_resource_group.resource-group-left.name
  virtual_network_name = azurerm_virtual_network.vnet_left.name
  address_prefixes       = ["10.9.8.0/24"]

  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]

}



# Create Network Security Group to Access Web VM left from Internet
resource "azurerm_network_security_group" "nsg-vm-web" {
  name                = "nsg-win-vm-web-left-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.resource-group-left.location
  resource_group_name = azurerm_resource_group.resource-group-left.name

  security_rule {
    name                       = "allow-rdp"
    description                = "allow-rdp from any internal network"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*" 
  }

security_rule {
    name                       = "allow-rdp-chicago-roki"
    description                = "allow-rdp-chicago-roki"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.home_ip
    destination_address_prefix = "*" 
  }


security_rule {
    name                       = "allow-rdp-work-vpn-roki"
    description                = "allow-rdp-work-vpn-roki"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.work_vpn_ip
    destination_address_prefix = "*" 
  }

security_rule {
    name                       = "allow-ssh-chicago-roki"
    description                = "allow-ssh-chicago-roki"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.home_ip
    destination_address_prefix = "*" 
  }


security_rule {
    name                       = "allow-ssh-work-vpn-roki"
    description                = "allow-ssh-work-vpn-roki"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.work_vpn_ip
    destination_address_prefix = "*" 
  }

  tags = {
   # application = var.app_name
    environment = var.environment 
    BackLogItem = var.BackLogItem
  }
}



# Win Web Server in Azure
module "win-web-one" {
  source = "./win-vm"

  vm_name     = "win-web-one"
  vm_rg_name  = azurerm_resource_group.resource-group-left.name 
  vm_location = azurerm_resource_group.resource-group-left.location
  vm_subnet_id= azurerm_subnet.def-subnet-left.id
  vm_storage_type = "StandardSSD_LRS"
  vm_size     = "Standard_D1_v2"
  admin_username = var.admin_username
  admin_password = var.admin_password
  network_security_group_id = azurerm_network_security_group.nsg-vm-web.id
  
  BackLogItem = var.BackLogItem
  environment = var.environment
  project_id  = var.project_id
}

# Lin Web Server in Azure
module "lin-web-one" {
  source = "./lin-vm"

  vm_name     = "lin-web-one"
  vm_rg_name  = azurerm_resource_group.resource-group-left.name 
  vm_location = azurerm_resource_group.resource-group-left.location
  vm_subnet_id= azurerm_subnet.def-subnet-left.id
  vm_storage_type = "StandardSSD_LRS"
  vm_size     = "Standard_D1_v2"
  admin_username = var.admin_username
  
  network_security_group_id = azurerm_network_security_group.nsg-vm-web.id
  
  BackLogItem = var.BackLogItem
  environment = var.environment
  project_id  = var.project_id
}


/* -----------------------------------------------------------------------
-
Outputs
-
*/


# Win VM Public IP
output "win-vm-web-left-left_public_ip" {
  value = module.win-web-one.win_vm_public_ip
}

# Lin VM Public IP
output "lin-vm-web-left-left_public_ip" {
  value = module.lin-web-one.lin_vm_public_ip
}
