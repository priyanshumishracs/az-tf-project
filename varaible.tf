# Resource Group
variable "resource_group_name" {
  type    = string
  default = "MPEDA-RG"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "vnet1_name" {
  type    = string
  default = "MPEDA-hub-Vnet"
}
variable "vnet1_address_space" {
  type    =  list(string)
  default = ["192.168.0.0/20"]
}

variable "Vnet1_subnet1_name" {
  type    = string
  default = "MPEDA-hub-subnet-1"
}
variable "Vnet1_subnet1_address_prefix" {
  type    = string
  default = "192.168.0.0/24"
}

variable "puplic_ip_name" {
  type    = string
  default = "MPEDA-prod-pub-ip1"
}
variable "LoadBalancer_name" {
  type    = string
  default = "MPEDA-prod-lb"
}
variable "lb_private_ip" {
  type = string
  default = "192.168.0.1"
}



variable "vnet2_name" {
  type    = string
  default = "MPEDA-prod-spoke-Vnet"
}
variable "vnet2_address_space" {
  type    =  list(string)
  default = ["10.0.0.0/16"]
}
variable "Vnet2_subnet1_name" {
  type    = string
  default = "MPEDA-prod-pub-subnet"
}
variable "Vnet2_subnet1_address_prefix" {
  type    = string
  default = "10.0.1.0/24"
}
variable "Vnet2_subnet2_name" {
  type    = string
  default = "MPEDA-prod-private-subnet"
}
variable "Vnet2_subnet2_address_prefix" {
  type    = string
  default = "10.0.2.0/24"
}

variable "windows_username" {
    type = string
    default = "Webadmin" # Example username for the VM
  
}
variable "linux_username" {
    type = list(string)
    default = ["Geoadmin", "Redisadmin", "Dbadmin"] # Example usernames for each VM
}

variable "nic_name" {
  type    = list(string)
  default = ["MPEDA-WebApp-nic", "MPEDA-GeoServer-nic", "MPEDA-redisServer-nic", "MPEDA-dbServer-nic"]
}


variable "windows-vm-name" {
    type = string
    default = "MPEDA-Webserver"
}
variable "windowsVmsize" {
  description = "List of VM sizes for the virtual machines"
  type        = list(string)
  default     = ["Standard_D4aS_v5"] 
}
variable "windows-vm-os-disk-name" {
  description = "List of OS disk names for each VM"
  type        = string
  default     = "MPEDA-WebApp-server-osdisk"
}
variable "Windows_os_disk_sizes" {
  description = "List of OS disk sizes for each VM"
  type        = list(number)
  default     = [128,] 
}


variable "linux_Vm_name" {
  type = list(string)
  default = ["MPEDA-Geo-server", "MPEDA-prod-redis-server", "MPEDA-db-server"] 
}
variable "linuxVmsize" {
  description = "List of VM sizes for the linux virtual machines"
  type        = list(string)
  default     = ["Standard_D16aS_v5", "Standard_D4aS_v5", "Standard_D8aS_v5"] # Example sizes
}
variable "linux_Vm_os_disk_name" {
  description = "List of OS disk names for each VM"
  type        = list(string)
  default     = ["MPEDA-prod-Geo-server-osdisk", "MPEDA-prod-redis-server-osdisk", "MPEDA-db-server-osdisk"] # Example names
}
variable "linuxVm_os_disk_sizes" {
  description = "List of OS disk sizes for each VM"
  type        = list(number)
  default     = [30, 30, 30, 30] # Different disk sizes for each VM
}


variable "subscription_id" {    
  type    = string
}
variable "tenant_id" {    
  type    = string
}
variable "client_id" {    
  type    = string
}
variable "client_secret" {    
  type    = string
}