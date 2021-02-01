
# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {


   key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}


/* -----------------------------------------------------------------------
-
Make RG in East US2 for VMs
-
*/

resource "azurerm_resource_group" "rg-one" {
  name     = "rgp-eastus2-${var.project_id}-${var.environment}"
  location = "East US2"
}

/* -----------------------------------------------------------------------

KeyVault

*/


data "azurerm_client_config" "current" {
}


module "keyvault" {
  source              = "./keyvault"
  name                = "kv-roki-test-01"
  location            = azurerm_resource_group.rg-one.location
  resource_group_name = azurerm_resource_group.rg-one.name
  
  enabled_for_deployment          = var.kv-vm-deployment
  enabled_for_disk_encryption     = var.kv-disk-encryption
  enabled_for_template_deployment = var.kv-template-deployment

  tags = {
    environment = var.environment
  }

  policies = {
    full = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = var.kv-full-object-id
      key_permissions         = var.kv-key-permissions-full
      secret_permissions      = var.kv-secret-permissions-full
      certificate_permissions = var.kv-certificate-permissions-full
      storage_permissions     = var.kv-storage-permissions-full
    }
    read = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = var.kv-read-object-id
      key_permissions         = var.kv-key-permissions-read
      secret_permissions      = var.kv-secret-permissions-read
      certificate_permissions = var.kv-certificate-permissions-read
      storage_permissions     = var.kv-storage-permissions-read
    }
  }

  secrets = var.kv-secrets
}



/* 

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "kv-roki-test-01"
  location                    = azurerm_resource_group.rg-one.location
  resource_group_name         = azurerm_resource_group.rg-one.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }
}
*/

/* -----------------------------------------------------------------------

Net

*/



resource "azurerm_virtual_network" "vnet_one" {

  name                = "vnet-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.rg-one.location
  resource_group_name = azurerm_resource_group.rg-one.name 

  address_space       = ["10.9.0.0/16"]

  tags = {
   # application = var.app_name
    environment = var.environment 
    BackLogItem = var.BackLogItem
  }

}

resource "azurerm_subnet" "def-subnet-one" {

  name                 = "sub-8-${var.project_id}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg-one.name
  virtual_network_name = azurerm_virtual_network.vnet_one.name
  address_prefixes       = ["10.9.8.0/24"]

  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]

}



# Create Network Security Group to Access Web VM left from Internet
resource "azurerm_network_security_group" "nsg-vm-web" {
  name                = "nsg-win-vm-web-left-${var.project_id}-${var.environment}"
  location            = azurerm_resource_group.rg-one.location
  resource_group_name = azurerm_resource_group.rg-one.name

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

/*

Get passwords from KeyVault

*/

data "azurerm_key_vault" "kv-roki-test" {
  name                = "kv-roki-test-01"
  resource_group_name = azurerm_resource_group.rg-one.name
}

data "azurerm_key_vault_secret" "abstract" {
  name = "abstract"
  #vault_uri = "https://kv-roki-test-01.vault.azure.net/"
  key_vault_id = data.azurerm_key_vault.kv-roki-test.id
}


# Win Web Server in Azure
module "win-web-one" {
  source = "./win-vm"

  vm_name     = "win-web-one"
  vm_rg_name  = azurerm_resource_group.rg-one.name 
  vm_location = azurerm_resource_group.rg-one.location
  vm_subnet_id= azurerm_subnet.def-subnet-one.id
  vm_storage_type = "StandardSSD_LRS"
  vm_size     = "Standard_D2_v4"
  admin_username = var.admin_username
  # admin_password = var.admin_password
  
  admin_password = data.azurerm_key_vault_secret.abstract.value

  network_security_group_id = azurerm_network_security_group.nsg-vm-web.id
  
  BackLogItem = var.BackLogItem
  environment = var.environment
  project_id  = var.project_id
}

# Lin Web Server in Azure
module "lin-web-one" {
  source = "./lin-vm"

  vm_name     = "lin-web-one"
  vm_rg_name  = azurerm_resource_group.rg-one.name 
  vm_location = azurerm_resource_group.rg-one.location
  vm_subnet_id= azurerm_subnet.def-subnet-one.id
  vm_storage_type = "StandardSSD_LRS"
  vm_size     = "Standard_D2_v4"
  admin_username = var.admin_username
  
  network_security_group_id = azurerm_network_security_group.nsg-vm-web.id
  
  BackLogItem = var.BackLogItem
  environment = var.environment
  project_id  = var.project_id
}

