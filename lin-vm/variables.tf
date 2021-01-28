
variable "vm_name" {
  description = "Name of the Win machinet. Must be unique."
  type = string
}

variable "vm_rg_name" {
  type = string
  description = "Name of the Resource Group"
}

variable "vm_location" {
  type = string
  description = "Location of the vm"
}

variable "vm_subnet_id" {
  type = string
  description = "Id of the subnet"
}

variable "vm_storage_type" {
  type = string
  description = "Storage account type to use for disk. Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."

}

variable "environment" {
  type = string
  description = "The environment for the machine to run"
}

variable "vm_size" {
  type = string
  description = "Size of the machine"
}

variable "admin_username" {
  type = string
  description = "The username of admin user"
}

variable "project_id" {
  type = string
  description = "Name of the project"
}

variable "network_security_group_id" {
  type = string
  description = "network_security_group_id to associate with interface"
}

variable "BackLogItem" {
  type = string
  description = "BackLog Item ID associated with the rosource"
  default = ""
  
}