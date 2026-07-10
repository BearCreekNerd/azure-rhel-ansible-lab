variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-ansible-safe-lab"
}

variable "vm_name" {
  type        = string
  description = "RHEL VM name"
  default     = "rhel-ansible-safe-01"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Linux VM"
  default     = "azureuser"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B2s"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vnet_name" {
  type        = string
  default     = "vnet-ansible-safe"
}

variable "vnet_cidr" {
  type        = string
  default     = "10.20.0.0/16"
}

variable "workload_subnet_name" {
  type        = string
  default     = "workload-subnet"
}

variable "workload_subnet_cidr" {
  type        = string
  default     = "10.20.1.0/24"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "Must be /26 or larger for Bastion"
  default     = "10.20.2.0/26"
}

variable "nsg_name" {
  type        = string
  default     = "nsg-workload"
}

variable "nic_name" {
  type        = string
  default     = "nic-rhel-safe-01"
}

variable "bastion_name" {
  type        = string
  default     = "bas-ansible-safe"
}

variable "bastion_pip_name" {
  type        = string
  default     = "pip-bastion-ansible-safe"
}
