terraform {
  required_version = ">= 1.6"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }

  # State lives in Postgres, not on the (rebuildable) container running Terraform.
  # Connection string comes from the PG_CONN_STR environment variable.
  backend "pg" {
    schema_name = "terraform_homelab"
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token # injected from Vault at run time, never committed
  insecure  = false                 # the API cert is issued by the internal CA
}
