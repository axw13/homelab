# Faster backups and quieter maintenance automation

A homelab remediation combined credential replacement, actual restore tests,
monitoring consolidation and repair of an AI CLI sandbox inside an unprivileged
container. Both AI providers remain available through the existing switch.

## Backup changes and measured results

Six NFS-root guest backups failed because fallback suspend-mode staging on
network storage could not preserve the required ownership and ACL behavior.
Local hypervisor staging repaired them; all six compressed archives passed
integrity checks, and three extracted application databases were checked.

Offsite backups now use consistent SQLite snapshots and an n8n PostgreSQL dump
instead of copying a live database directory. Individual file payloads and
uncompressed SQL let Restic deduplicate before compression/encryption. Monitoring
configuration is retained while historical telemetry stays in local guest backups.
Original guest ownership is recorded for restoring nonstandard container UIDs.

The measured MEGA upload decreased from 17m50s to 7m07s; newly stored data fell
from 3.641 GiB to 1.809 GiB, including the initial format migration. These are
upload timings, not total job duration or a promise for every future run.
Retention selection runs nightly and bounded repacking weekly. Success heartbeats
are validated, private staging is cleaned on exit, and persistent upload helpers
cannot inherit the job lock.

Actual downloaded backups were restored into scratch databases. n8n recovered
59 workflows and nine encrypted credential records; application SQLite integrity
checks passed. Restored monitoring configuration populated hosts, items and
triggers with empty historical telemetry as designed. Scratch databases were
removed without restoring over production. This is not a full physical-host DR drill.

## Monitoring and incident behavior

Zabbix and Wazuh replace legacy monitoring service processes. Their old guests,
disks and OS/security monitoring remain for reversible recovery. NAS pool/disk
health and hypervisor SMART checks have native coverage. Unsupported collectors
and obsolete version-specific counters were corrected or disabled when inapplicable.
Unavailable home-automation measurements remain visibly unavailable rather than
being written as healthy zeros.

Events deduplicate by exact host and trigger, respect maintenance/suppression,
and begin verification on recovery. Informational package changes do not start
AI investigations. Dispatchers share a lock; unchanged escalations have a six-hour
cooldown. A deterministic verifier checks real conditions every 15 minutes without
AI calls or chat notifications, and requires three healthy days before closure.
Stale data and observation gaps reset or prevent a healthy claim.

A WAN degradation trigger now supports an expected-speed recovery baseline,
so restoring the physical link speed clears an event even after its original
speed-change sample has passed. Logical PPP interface rates are kept distinct
from physical Ethernet negotiation.

## Credentials and sandbox

Four exposed credentials were replaced, deployed consumers updated, and new
and old authentication tested. Event workflows read secrets at runtime using a
short-lived scoped AppRole. Native chat credentials synchronize their encrypted
store from Vault when the owner replaces the bot token. Bot-token revocation
remains an owner action. Runtime job state is ignored/untracked locally preserved;
Git history was not rewritten.

The AI sandbox required container-scoped nesting and AppArmor mount permissions
in addition to bubblewrap. The container remains unprivileged with AppArmor
active. Read-only writes, writes outside the workspace and direct network access
were denied; workspace writes succeeded. No hypervisor restart was performed.
