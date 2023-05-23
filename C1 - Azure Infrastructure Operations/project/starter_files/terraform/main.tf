provider "azurerm" {
  features {}
}

#resource "azurerm_resource_group" "main" {
#  name     = "${var.resource_name}-rg"
#  location = var.location
#  tags     = {
#    long-udacity = "${var.resource_name}-project-1"
#  }
#}

data "azurerm_resource_group" "main" {
  name = "Azuredevops"
}

// Main virtual network, subnets, nics and public IPs
resource "azurerm_virtual_network" "main" {
  name                = "${var.resource_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.resource_name}-internal-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.resource_name}-public-ip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Dynamic"

  tags = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

resource "azurerm_network_interface" "main" {
  count               = var.numberofvms
  name                = "${var.resource_name}-nic-${count.index}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  ip_configuration {
    name                          = "${var.resource_name}-primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

// Secutiy Group
resource "azurerm_network_security_group" "webserver" {
  name                = "${var.resource_name}-webserver-sg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

resource "azurerm_network_security_rule" "internal-inbound" {
  name                        = "internal-inbound-rule"
  resource_group_name         = "${data.azurerm_resource_group.main.name}"
  network_security_group_name = "${azurerm_network_security_group.webserver.name}"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
}

resource "azurerm_network_security_rule" "internal-outbound" {
  name                        = "internal-outbound-rule"
  resource_group_name         = "${data.azurerm_resource_group.main.name}"
  network_security_group_name = "${azurerm_network_security_group.webserver.name}"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
}

resource "azurerm_network_security_rule" "external" {
  name                        = "external-rule"
  resource_group_name         = "${data.azurerm_resource_group.main.name}"
  network_security_group_name = "${azurerm_network_security_group.webserver.name}"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

// Load balancer
resource "azurerm_lb" "main" {
  name                = "${var.resource_name}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  frontend_ip_configuration {
    name                 = "${var.resource_name}-public-address"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
  tags = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  //resource_group_name = data.azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.main.id
  name            = "udacity-ahmed-rg-backend-address-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.numberofvms
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name   = "${var.resource_name}-primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

resource "azurerm_availability_set" "avset" {
  name                = "${var.resource_name}-avset"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.numberofvms
  name                            = "${var.resource_name}-vm-${count.index}"
  resource_group_name             = data.azurerm_resource_group.main.name
  source_image_id                 = var.image_id
  location                        = data.azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  availability_set_id             = azurerm_availability_set.avset.id
  disable_password_authentication = false
  network_interface_ids           = [
    azurerm_network_interface.main[count.index].id,
  ]
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = {
    long-udacity = "${var.resource_name}-project-1"
  }
}

resource "azurerm_managed_disk" "data" {
  count                = var.numberofvms
  name                 = "${var.resource_name}-disk-${count.index}"
  location             = data.azurerm_resource_group.main.location
  create_option        = "Empty"
  disk_size_gb         = 10
  resource_group_name  = data.azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  tags                 = {
    long-udacity = "${var.resource_name}-project-1"
  }

}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  virtual_machine_id = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  managed_disk_id    = element(azurerm_managed_disk.data.*.id, count.index)
  lun                = 1
  caching            = "None"
  count              = var.numberofvms
}