packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.0.0"
    }
  }
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  use_azure_cli_auth ="true"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts"
  location                          = "East US"
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "AppliedProjects"
  os_type                           = "Linux"
  subscription_id                   = "f7819382-1199-4106-937c-e780748fd273"
  tenant_id                         = "ec1bd924-0a6a-4aa9-aa89-c980316c0449"
  vm_size                           = "Standard_DS2_v2"
  ssh_username                      = "azureuser"
}

build {
  sources = ["source.azure-arm.ubuntu"]
}
