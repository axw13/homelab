# Deterministic security monitoring implementation

The earlier assessment found useful SIEM telemetry without reliable automated incident delivery. A deterministic collector now runs every two minutes independently of AI quota, backed by a durable notification outbox and an independent availability-monitoring watchdog.

## Implemented behavior

- Read-only manager/indexer API identities, short-lived scoped Vault authentication and pinned SIEM TLS certificates. Administrative writes are denied; a wrong certificate fingerprint fails closed.
- Fifteen metrics and eight watchdogs cover collector heartbeat, manager processes, indexer/query health, event freshness, expected agents, indexed inventory, IOC configuration and queued delivery.
- Actionable events are correlated, paginated with overlap, retried and delivered to an issue tracker and Telegram. Initial delivery does not require AI; subsequent AI involvement is constrained to read-only triage. Automatic blocking remains off.
- Daily vulnerability, package-inventory, coverage and CIS/SCA summaries, plus a weekly hardening review. Vulnerability baselines exclude obsolete enrollment identities and distinguish host/package records from unique exploitable vulnerabilities.
- Three packaged IOC lookup lists now compile and load. An offline positive SSH sample matches the threat-indicator rule; a negative control matches the ordinary SSH rule. No production attack was performed.
- A narrowly scoped rule removes confirmed container proc-mount noise while preserving other rootcheck findings. Generic binary warnings were investigated against repository packages; repeated patterns are correlated rather than treated as proof of compromise.
- The missing listening-port collection dependency was restored across the Linux fleet. The inventory connector's broken local indexer endpoint was repaired without weakening TLS, and inventory/vulnerability indices rebuilt.
- Notification/cursor state is consistently snapshotted into the encrypted nightly backup, with recovery instructions and a retained rollback path.

## Verification and limits

Seventeen tests cover routing, correlation, sensitive paths, scope, replay, persistence, transport retry and retained cursors after failure. A labelled synthetic notification was delivered, its test issue read back and closed, and replay sent no duplicate. Actual scheduled runs and availability metrics were verified. Delivery is at least once: an ambiguous Telegram timeout after acceptance can still duplicate a message.

Agent coverage is explicit rather than assumed: two Linux enrollments await the operator's firewall alias correction, and a Windows installation guide is prepared for local administrator execution. Appliance, application-log, network IDS and container-image vulnerability coverage remain separate considerations. A faulty USB device still needs physical attention; its raw events were not globally hidden. All central monitoring components remain on one physical server, so logical watchdog independence does not provide external power-outage monitoring.

The operator's two AI-provider integrations and authentication remain preserved. No firewall configuration change, automatic blocking or hypervisor reboot was performed.

References: [Wazuh CDB lists](https://documentation.wazuh.com/current/user-manual/ruleset/cdb-list.html), [System inventory](https://documentation.wazuh.com/current/user-manual/capabilities/system-inventory/how-it-works.html), [Vulnerability detection](https://documentation.wazuh.com/current/user-manual/capabilities/vulnerability-detection/how-it-works.html).
