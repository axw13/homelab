# Reducing incident noise without disabling security monitoring

An operator-requested review examined 63 open incidents and closed 53 with an
individual explanation: 29 expected shared-kernel inventory changes after a power
cut, 21 package-count changes from an authorized monitoring dependency installation,
one binary-signature false positive verified against repository packages, one
duplicate agent/inventory coverage report and a cleared dispatcher storm summary.
Ten genuine work or recovery-review issues remained open.

The event dispatcher now excludes only two exact inventory-change trigger names at
their normal low severity. Both problem and recovery notifications are filtered
before incident creation. Observations remain available in Zabbix. Higher-severity
or unknown-severity events, security findings, file-integrity changes and service
availability alarms still pass through. This avoids treating a package-count change
as an incident while retaining actual package vulnerability monitoring.

The maintenance dispatcher also stopped appending identical storm-cap comments
every three minutes. It updates one existing summary when the pending list changes.
The investigation quota remains enabled. Duplicate coverage reports were consolidated
without claiming missing agents had recovered or disabling their health checks.

Verification included offline boundary fixtures against the actual event parser,
isolated shell tests using mock HTTP for unchanged and changed storm summaries,
live active-workflow readback, and comment/state readback for every closed incident.
No maintenance wrapper or production alert was invoked merely as a test. Raw
security evidence, both AI integrations and recovery observation windows were retained.

## Operator-approved closure exceptions

The operator subsequently removed the blanket three-day hold for completed
updates and specific self-clearing restart/delivery notices. Six additional
issues were closed after fresh verification or explicit disposition of historical
update tracking. Four genuine security/performance work items remained open.

The deterministic verifier uses an exact allowlist for one-check closure.
Disabled, unsupported or stale monitoring cannot pass. Home automation updates
also require a direct live installed/latest version match and no installation in
progress; skipping a release is not completion. Recovery webhooks alone cannot
close incidents. Unknown conditions and recurring availability/performance faults
retain their measured recovery window. Security findings and missing coverage
remain open until addressed. Remaining routine package availability stays in
update reports and does not imply an update or reboot was performed.

Policies, workflow messages and regression tests were updated to reflect this
distinction. Tests cover exact-name boundaries, preserved security/unknown handling,
and skipped, unknown or in-progress updates.

## Reducing security false positives at the source

A later security burst came from mutable application databases and broad binary
string signatures. Incident routing now recognizes only the specific reviewed
runtime-file patterns, requiring expected owner/group/permissions and an explicit
change-attribute list. Configuration and authentication-key changes, unexpected
paths, privilege changes and higher-severity findings still alert. Raw FIM events
remain searchable; no broad directory exclusions were introduced.

The four affected binary hashes were revalidated against signed Debian release,
index and package artifacts. All 30 affected hosts passed fresh version, SHA256,
size, ownership, mode and alias checks. Future exact generic-signature events
require fresh per-host attestation before going to summary counters. Changed or
unreachable hosts and unknown versions still require investigation. Probes are
read-only, use fixed commands and validated SSH host keys, and never execute the
flagged binaries.

An offline replay of the complete 238-event incident sample reduced four incident
groups to one (75%), retaining sensitive hypervisor configuration/key changes.
This measures that sample, not all future traffic. Twenty-eight collector/filter
tests and four closure-policy tests passed. Scheduled collection stayed healthy.

Critical vulnerability identity now survives enrollment-ID changes and brief
index rebuild gaps. New package versions/CVEs and reintroduction after a full day
of absence remain actionable. Cleared dispatch-cap summaries close only with a
fresh dispatcher heartbeat and empty work queue. Vendor-validated vulnerabilities,
missing coverage and genuine hardware/performance tasks remain visible.
