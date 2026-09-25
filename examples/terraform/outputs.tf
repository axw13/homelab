# Consumed by the Ansible dynamic inventory: hostname -> IP and VLAN.
output "inventory" {
  value = {
    for name, c in local.containers : name => {
      ip   = cidrhost(local.vlans[c.vlan].cidr, c.host)
      vlan = c.vlan
    }
  }
}
