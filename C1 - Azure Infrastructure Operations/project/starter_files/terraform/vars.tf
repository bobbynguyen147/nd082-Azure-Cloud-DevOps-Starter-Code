variable "location" {
  description = "location"
  default     = "North Europe"
}

variable "image_id" {
  description = "image_id"
  default     = "/subscriptions/21347db0-e426-46ac-b8a8-cb3f9fee02da/resourceGroups/udacity-ahmed-rg/providers/Microsoft.Compute/images/udacity-packer-image"
}

variable "admin_username" {
  description = "Enter username to associate with the machine"
  default     = "longnguyen"
}

variable "resource_group_name" {
  description = "rsg"
  default     = "udacity-project1-rsg"
}

variable "admin_password" {
  description = "Enter password to use to access the machine"
  default     = "123@123aA"
}

variable "numberofvms" {
  description = "number of VMs to create"
  default     = 1
  type        = number 
}