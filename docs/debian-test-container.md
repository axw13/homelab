# Reproducible Debian test container

Provisioned a Debian 12 Bookworm testing LXC with an unprivileged container,
2 vCPU, 2 GiB RAM and a 16 GiB SSD root disk. A per-guest template override
preserves the existing Debian 13 defaults for other containers. A reviewed,
targeted Terraform plan created only the new guest and its credential resources.

Configured a named administrator account with a Vault-backed password, sudo that
requires authentication, and an existing administration public key. Root SSH uses
keys. Credentials are absent from source and documentation. Inventory and IPAM
records reflect the guest and its assigned address outside the DHCP pool.

Verification exercised password-only SSH, actual user identity, password-authenticated
sudo returning root, OS identity, DNS and HTTPS from the guest. The host key was
verified through the hypervisor before connecting. Repeating the account/SSH
bootstrap reported no changes.

The actual Ansible playbook passed with seven successful tasks and zero changes
after bootstrap; a refreshed targeted Terraform plan also reported no changes.
The guest is minimal testing compute;
production monitoring, application exposure and application-data backups require
the normal service-promotion checklist.
