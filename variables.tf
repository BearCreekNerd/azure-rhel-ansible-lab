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

variable "ssh_public_key" {
  type        = string
  description = "SSH public key content (e.g. ssh-ed25519 AAAA... user@host)"

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ", var.ssh_public_key))
    error_message = "ssh_public_key must be a valid OpenSSH public key starting with ssh-ed25519, ssh-rsa, or ecdsa-sha2-*."
  }
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR allowed to SSH to the VM"
  default     = "0.0.0.0/0"
}

variable "vnet_name" {
  type    = string
  default = "vnet-ansible-safe"
}

variable "vnet_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "workload_subnet_name" {
  type    = string
  default = "workload-subnet"
}

variable "workload_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "nsg_name" {
  type    = string
  default = "nsg-workload"
}

variable "nic_name" {
  type    = string
  default = "nic-rhel-safe-01"
}

variable "vm_public_ip_name" {
  type    = string
  default = "pip-rhel-safe-01"
}
