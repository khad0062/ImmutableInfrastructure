terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "f7819382-1199-4106-937c-e780748fd273"
  features {
    
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "deployment-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
    name               = "image-nic"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    
   ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Add subnet, NIC, NSG, and VM using image
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "my-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "packer"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
  source_image_id = "/subscriptions/f7819382-1199-4106-937c-e780748fd273/resourceGroups/AppliedProjects/providers/Microsoft.Compute/images/myPackerImage"



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myosdisk1"
  }

  admin_ssh_key {
    username   = "packer"
    public_key = file("~/.ssh/id_rsa.pub") // Update path if your public key is elsewhere
  }
}
