# Open issue repair and verification — 2026-10-09

Reviewed every open incident and recorded the actual condition and next action
in each. Home Assistant Core was upgraded from 2026.9.4 to 2026.10.0 after a
native full backup, archive validation, configuration check and review of the
release's breaking changes. Post-update configuration passed, Supervisor is
healthy, integration setup has no failures, and repaired ESPHome devices still
provide live readings. The full pre-update backup remains available for rollback.

Corrected the deterministic verifier for a news workflow that runs every four
hours with a five-hour deployed no-data deadline. Its former generic two-hour
freshness test incorrectly reset healthy observation between successful runs.
The verifier now reads the bounded deployed deadline, still requiring enabled,
supported and successful inputs. Six boundary cases passed; the last three real
executions succeeded. The workflow schedule and alert threshold were retained.

Corrected Vault-backed monitoring frontend/API address metadata without changing
credentials. The monitoring API uses the actual frontend port and its JSON-RPC
endpoint; callers should read the canonical metadata. Authenticated lookup was
verified. Monitoring returned to zero enabled unsupported items after collection
recovered from the application restart and previous transient Docker timeouts.

All 14 repair incidents currently pass live checks. They remain open during
measured three-day verification windows. A regression or an observation gap
over six hours resets the affected window. The hypervisor restart remains a
separate manual operator action scheduled for a few days later; no hypervisor
reset or guest stop was performed. Verify kernel, guest startup, monitoring and
backups afterward.

Two previously blocked security agents now have correct firewall alias members
and are Active. Two others still have bare hostnames where actual IP members
are required; the operator must correct and apply those members before their
enrollment can be verified. Firewall configuration remains human-only. Complete
security coverage is not claimed. Telegram credential revocation remains an
owner action, with downstream Vault consumer synchronization already scheduled.

Remaining live alerts for a router integration update and storage-server memory
were outside the reviewed incident list and were not claimed resolved.

Related procedures: [backup and monitoring remediation](backup-monitoring-remediation.md)
and [ESPHome connection recovery](esphome-connection-recovery.md).
HA upgrade reference: [2026.10 release notes](https://www.home-assistant.io/blog/2026/10/07/release-202610/).
