
variable "subscription_id" {}
variable "tenant_id" {}

variable "environment" {
  type = string
  description = "Something like test, dev or prod to add to the names of objects"
}


variable "project_id" {
  type = string
  description = "Just a substring to add to created objects to make them uniquie"
}

# Windows VM Admin User
variable "admin_username" {
  type        = string
  description = "Windows VM Admin User"
}

# Windows VM Admin Password
variable "admin_password" {
  type        = string
  description = "Windows VM Admin Password"
}


variable "home_ip" {
    type = string
    description = "IP address which has RDP access to the server by default"
}

variable "work_vpn_ip" {
    type = string
    description = "IP address which has RDP access to the server by default"
}


variable "BackLogItem" {
  type = string
  description = "BackLog Item ID associated with the rosource"
}