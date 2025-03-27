resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.vnet_address_space
}

# Subnet1
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet1_address_prefix]

    lifecycle {
    ignore_changes = [address_prefixes] # Prevents Terraform from modifying subnet1's address prefix
  }
}

# Subnet2
resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet2_address_prefix]
}

# Generate Random Passwords
resource "random_password" "passwords" {
  count   = 5
  length  = 16
  special = true
}

# nic
resource "azurerm_network_interface" "nic" {
  count               = 5
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_subnet.subnet1, azurerm_subnet.subnet2]  # Ensure subnets exist first
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = count.index < 2 ? azurerm_subnet.subnet1.id : azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

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
    name                 = "windows-vm-${count.index}-osdisk"
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

resource "azurerm_linux_virtual_machine" "linuxvm" {
  count               = 4
  name                = "linuxvm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = element(var.linuxVmsize, count.index)

  admin_username      = var.username
  disable_password_authentication = false
 admin_password      = random_password.passwords[count.index].result
  
  network_interface_ids = [azurerm_network_interface.nic[count.index + 1].id]
  
  os_disk {
    name                 = "lixuxvm-${count.index}-osdisk"
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
    [ "Windows VM | User: adminuser | Password: ${random_password.passwords[0].result} | Private IP: ${azurerm_network_interface.nic[0].private_ip_address}" ],
    [ for i in range(4) : "Linux VM-${i+1} | User: adminuser | Password: ${random_password.passwords[i+1].result} | Private IP: ${azurerm_network_interface.nic[i+1].private_ip_address}" ]
  ))
  filename = "${path.module}/vm_credentials.txt"
}
