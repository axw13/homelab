# War stories

Real incidents this lab has hit and resolved. Each one follows the same layout: **Symptom → Investigation → Root cause → Fix → Lesson** (design write-ups use Problem/Approach in place of Symptom/Investigation).

## Start here
| Story | One-line summary |
|---|---|
| [Multi-drive NAS pool failure cascade](nas-pool-failure-cascade.md) | A failing drive's bus noise looked like a second failure; rebuilt for reliability and moved hot workloads off shared storage |
| [Media-server freezes caused by five other services](cross-service-disk-contention.md) | Five services' unpruned history quietly overloaded weak SSDs; fixed each at the source |
| [Three distinct bugs behind one "timeout" symptom](ai-gateway-three-bugs.md) | Quota counted on acceptance, mismatched timeouts, a stale in-memory timer |
| [A wall of identical "load too high" alerts](container-load-average-false-alarms.md) | LXC containers report the hypervisor's load average, not their own |

## Networking & VPN
- [Management-network outage during a VLAN migration](management-network-outage.md)
- [A WireGuard peer whose replies vanished](wireguard-nat-gap.md)
- [Proving a second VPN path actually works](subnet-router-differential-test.md)
- [Migrating the smart-home fleet onto its own IoT VLAN](iot-vlan-migration.md)

## Automation & IaC
- [Designing patch automation that respects IaC](iac-drift-aware-patching.md)
- [An automation bug hidden by a lenient error handler](masked-automation-bug.md)
- [A silently ignored API filter during a forward-auth rollout](forward-auth-api-filter.md)

## Systems, containers & home automation
- [A fleet-wide NTP change that silently did nothing](ntp-silent-no-op.md)
- [A third-party Docker image with a broken dependency tree](broken-docker-dependency-tree.md)
- ["Everything is offline" after a power outage](power-outage-static-ip-cascade.md)
- [An "invalid auth" error that wasn't about credentials](camera-third-party-toggle.md)

## Backup & recovery
- [Dry-running the disaster-recovery procedure](dr-dry-run.md)
