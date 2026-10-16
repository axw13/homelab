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
