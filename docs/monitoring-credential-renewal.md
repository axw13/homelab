# Preventing expired monitoring credentials

A static Vault monitoring token had expired while the secrets service itself
remained healthy. The repair uses the existing metrics policy and a renewable
periodic credential rather than changing policies or distributing a root token.
The monitoring macro is stored as a secret, and the expired credential was
redacted from an older issue comment.

A persistent systemd timer renews the credential twice daily. The helper runs
as the service's unprivileged account and receives its credential through
systemd LoadCredential from a root-only file. It calls renew-self and logs only
success, lifetime or generic HTTP errors. A seven-day period leaves a renewal
buffer; monitoring still detects expiration if renewal stops working.

An Ansible role deploys the existing credential and units with no_log on secret
operations. It does not create credentials or modify Vault policies. Validation
includes live renewal before and after the application upgrade, fresh monitoring
data, an actual secrets read, and four regression tests for successful renewal,
expired credentials, network failures and insufficient lifetime. Error output
is checked to ensure it cannot expose the credential.

The broader issue review also corrected an update check that guessed the wrong
port for a Docker application. Update plans now require a working health-check
baseline and wait briefly for package-manager locks without deleting them or
killing their owner. Protected upgrades retain verified backups and rollback
material; the hypervisor reboot remains an operator action. Planned maintenance
is recorded in the issues and monitored without fighting the responsible task.

Periodic credential behavior follows the official
[Vault token documentation](https://developer.hashicorp.com/vault/docs/concepts/tokens).
