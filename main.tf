# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network 1
resource "azurerm_virtual_network" "hub_vnet1" {
  name                = var.vnet1_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.vnet1_address_space
}

# Vnet1-Subnet1
resource "azurerm_subnet" "Hub_subnet1" {
  name                 = var.Vnet1_subnet1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet1.name
  address_prefixes     = [var.Vnet1_subnet1_address_prefix]
}

resource "azurerm_public_ip" "Pub-ip" {
  name                = var.puplic_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "example" {
  name                = var.LoadBalancer_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.puplic_ip_name
    public_ip_address_id = azurerm_public_ip.Pub-ip.id
  }

  frontend_ip_configuration {
    name      = "InternalFrontend"
    subnet_id = azurerm_subnet.Hub_subnet1.id  # ✅ Internal Subnet inside VNet
    private_ip_address_allocation = "static"
  }
  depends_on = [azurerm_public_ip.Pub-ip, azurerm_subnet.Hub_subnet1]  # Ensure Public IP is created first]
}

# Virtual Network 2
resource "azurerm_virtual_network" "vnet2" {
  name                = var.vnet2_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.vnet2_address_space
  depends_on = [azurerm_virtual_network.hub_vnet1]  # Ensure hub_vnet1 exists first
}

# Vnet2-Subnet1
resource "azurerm_subnet" "subnet1" {
  name                 = var.Vnet2_subnet1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = [var.Vnet2_subnet1_address_prefix]

}


# Vnet2-Subnet2
resource "azurerm_subnet" "subnet2" {
  name                 = var.Vnet2_subnet2_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = [var.Vnet2_subnet2_address_prefix]
  depends_on = [ azurerm_subnet.subnet1]             # Ensure subnet1 exists first
}


# Generate Random Passwords
resource "random_password" "passwords" {
  count   = 4
  length  = 16
  special = true
}


# nic for all vms
resource "azurerm_network_interface" "nic" {
  count               = 4
  name                = var.nic_name[count.index]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_subnet.subnet1, azurerm_subnet.subnet2]  # Ensure subnets exist first
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = count.index < 2 ? azurerm_subnet.subnet1.id : azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Windows VMs
resource "azurerm_windows_virtual_machine" "winvm" {
  count               = 1
  name                = var.windows-vm-name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = element(var.windowsVmsize, count.index)
  admin_username      = var.username
  admin_password      = random_password.passwords[0].result
  network_interface_ids = [azurerm_network_interface.nic[0].id]
  
  os_disk {
    name                 = var.windows-vm-os-disk-name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"                # Standard HDD for OS disk
    disk_size_gb         = element(var.Windows_os_disk_sizes, 0) # Using a fixed disk size for Windows VM
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

 # Linux VMs

resource "azurerm_linux_virtual_machine" "linuxvm" {
  count               = 3
  name                = element(var.linux_Vm_name, count.index)                                    #  "linuxvm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = element(var.linuxVmsize, count.index)

  admin_username      = var.username
  disable_password_authentication = false
 admin_password      = random_password.passwords[count.index + 1].result
  
  network_interface_ids = [azurerm_network_interface.nic[count.index + 1].id]
  
  os_disk {
    name                 = element(var.linux_Vm_os_disk_name, count.index)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"                          # Standard HDD for OS disk
    disk_size_gb         = element(var.linuxVm_os_disk_sizes, count.index) # Using element() to get the disk size from the list
  }
  
   source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# Save VM Credentials Locally (Without Public IP)
resource "local_file" "vm_credentials" {
  content  = join("\n", concat(
    [ "Windows VM  | User: adminuser | Password: ${random_password.passwords[0].result} | Private IP: ${azurerm_network_interface.nic[0].private_ip_address}" ],
    [ for i in range(3) : "linuxvm-${i+1} | User: adminuser | Password: ${random_password.passwords[i+1].result} | Private IP: ${azurerm_network_interface.nic[i+1].private_ip_address}" ]
  ))
  filename = "${path.module}/vm_credentials.txt"
}
