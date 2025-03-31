# Resource Group
variable "resource_group_name" {
  type    = string
  default = "MPEDA-rg"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "vnet_name" {
  type    = string
  default = "MPEDA-Vnet"
}

variable "vnet_address_space" {
  type    =  list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet1_name" {
  type    = string
  default = "MPEDA-subnet-1"
}

variable "subnet1_address_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet2_name" {
  type    = string
  default = "MPEDA-subnet-2"
}

variable "subnet2_address_prefix" {
  type    = string
  default = "10.0.2.0/24"
}

variable "username" {
    type = string
    default = "AzureUser"
}


variable "nic_name" {
  type    = list(string)
  default = ["MPEDA-windows-nic1", "MPEDA-linux-nic1", "MPEDA-linux-nic2", "MPEDA-linux-nic3", "MPEDA-linux-nic4"]
}

variable "windows-vm-name" {
    type = string
    default = "Server2-webapp"
}


variable "windowsVmsize" {
  description = "List of VM sizes for the virtual machines"
  type        = list(string)
  default     = ["Standard_B1s"] 
}
variable "Windows_os_disk_sizes" {
  description = "List of OS disk sizes for each VM"
  type        = list(number)
  default     = [128,] 
}

variable "linux_Vm_name" {
  type = list(string)
  default = ["linux-vm1st", "linux-vm2nd", "linux-vm3rd", "linux-vm4th"] 
}

variable "linuxVmsize" {
  description = "List of VM sizes for the linux virtual machines"
  type        = list(string)
  default     = ["Standard_B1s", "Standard_B1s", "Standard_B1s", "Standard_B2s"] # Example sizes
}
variable "linuxVm_os_disk_sizes" {
  description = "List of OS disk sizes for each VM"
  type        = list(number)
  default     = [30, 30, 30, 30] # Different disk sizes for each VM
}