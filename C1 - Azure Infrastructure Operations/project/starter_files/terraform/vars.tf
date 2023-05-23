variable "location" {
  description = "location"
  default     = "West Europe"
}

variable "image_id" {
  description = "image_id"
  default     = "/subscriptions/a3a536c2-3690-4c5f-8032-998a8dc3234e/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/ubuntu-Image-project1"
}

variable "admin_username" {
  description = "Enter username to associate with the machine"
  default     = "longnguyen"
}

variable "resource_name" {
  description = "rsg"
  default     = "long-udacity"
}

variable "admin_password" {
  description = "Enter password to use to access the machine"
  default     = "Fpt123@a"
}

variable "numberofvms" {
  description = "number of VMs to create"
  default     = 2
  type        = number
}