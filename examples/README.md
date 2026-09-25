# Examples — sanitized IaC patterns

The real Terraform/Ansible source for the lab lives in a private repository (it contains real topology). These are **cut-down, sanitized versions of the same patterns**, with placeholder addresses, IDs and hostnames, so the approach described in the [main README](../README.md) can be read as code.

They're checked in CI (`terraform validate`, `ansible-playbook --syntax-check`, yamllint) but aren't meant to be applied as-is.

## [`terraform/`](terraform/) — one JSON entry per container

- [`containers.json`](terraform/containers.json) is the single source of truth for every LXC: VMID, VLAN, host octet, CPU/RAM/disk and storage backend.
- [`main.tf`](terraform/main.tf) turns it into real containers with one `for_each` over `bpg/proxmox`'s `proxmox_virtual_environment_container`. The IP is computed from the VLAN's CIDR and the host octet, so the address and the VLAN can't disagree.
- State goes to a Postgres backend ([`versions.tf`](terraform/versions.tf)), so the container running Terraform can be rebuilt without losing it.
- The Proxmox API token is a sensitive variable read from Vault at run time, never kept in a tfvars file.
- `outputs.tf` exports a hostname → IP/VLAN map for the Ansible inventory.

Adding a service: add a JSON entry, write a role, `terraform apply`.

## [`ansible/`](ansible/) — "get or create" secrets in Vault

[`roles/vault_secret`](ansible/roles/vault_secret/tasks/main.yml) is the pattern every service role uses for credentials:

1. Read the KV v2 secret at a known path. A *missing* path is the first-deploy case; any other error (permission denied, sealed, unreachable) still fails.
2. Keep every key that already exists, so a re-run never rotates a credential out from under a live integration.
3. Generate a separate random value for each missing key, write back the merged secret, and publish it as a fact for the calling role.

Every Vault call is `delegate_to: localhost` + `run_once`: the target host is on a VLAN that can't reach the security segment, and all hosts in the play must share one generated value.

Checked against a local Vault dev server: an existing key is preserved, missing keys get distinct values, a second run changes nothing (the secret version doesn't move), all hosts see identical values, and a bad token fails the play.

[`roles/example_app`](ansible/roles/example_app/tasks/main.yml) shows how a service role uses it: secrets first, then templated config, then its reverse-proxy site block, delegated to the proxy host.

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
export VAULT_ADDR=https://vault.example.internal:8200 VAULT_TOKEN=...
ansible-playbook site.yml
```
