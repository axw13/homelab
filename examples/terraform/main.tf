# Every LXC in the lab is one entry in containers.json. Adding a service is:
#   1. add an entry there, 2. write an Ansible role, 3. terraform apply.
locals {
  containers = jsondecode(file("${path.module}/containers.json"))
  vlans      = jsondecode(file("${path.module}/vlans.json"))
}

resource "proxmox_virtual_environment_container" "lxc" {
  for_each = local.containers

  node_name     = var.proxmox_node
  vm_id         = each.value.vmid
  description   = each.value.description
  tags          = sort(concat(["terraform", each.value.vlan], lookup(each.value, "tags", [])))
  unprivileged  = true
  start_on_boot = true
  started       = true

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory_mb
    swap      = 512
  }

  # Most containers sit on local SSD; a few that need bulk space use NFS on the NAS.
  disk {
    datastore_id = each.value.storage
    size         = each.value.disk_gb
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    vlan_id = local.vlans[each.value.vlan].id
  }

  initialization {
    hostname = each.key

    ip_config {
      ipv4 {
        address = "${cidrhost(local.vlans[each.value.vlan].cidr, each.value.host)}/${split("/", local.vlans[each.value.vlan].cidr)[1]}"
        gateway = local.vlans[each.value.vlan].gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }

  features {
    nesting = lookup(each.value, "nesting", false)
  }

  lifecycle {
    # The template is only used at creation; changing the default later must not
    # force every existing container to be destroyed and recreated.
    ignore_changes = [operating_system[0].template_file_id]
  }
}
