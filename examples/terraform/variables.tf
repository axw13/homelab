variable "proxmox_endpoint" {
  description = "Proxmox API URL, e.g. https://pve.example.internal:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (user@realm!token=secret). Read from Vault, never stored in tfvars."
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node that hosts the containers."
  type        = string
  default     = "pve"
}

variable "bridge" {
  description = "VLAN-aware Linux bridge the container NICs attach to."
  type        = string
  default     = "vmbr0"
}

variable "template_file_id" {
  description = "LXC template volume, e.g. local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  type        = string
}

variable "ssh_public_key" {
  description = "Public key installed for root so Ansible can take over after creation."
  type        = string
}

variable "dns_servers" {
  description = "Resolvers handed to every container."
  type        = list(string)
  default     = ["10.20.0.53"]
}
