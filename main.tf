provider "azurerm" {
  features {}
  # If using service principal for authentication
  # subscription_id = "AMC_SUBSCRIPTION_ID"
  # client_id       = "AMC_AZURE_CLIENT_ID"
  # client_secret   = "AMC_AZURE_CLIENT_SECRET"
  # tenant_id       = "AMC_AZURE_TENANT_ID"
}

resource "azurerm_resource_group" "rg" {
  name     = "TicketMonitorRG"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "TicketMonitorVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "TicketMonitorSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "TicketMonitorNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "TicketMonitorNICConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "TicketMonitorVM"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssword1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "init" {
  name                 = "TicketMonitorVMInit"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "./install_script.sh"
    }
SETTINGS
}
