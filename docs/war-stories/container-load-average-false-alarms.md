# A wall of identical "load too high" alerts

**Area:** monitoring · Zabbix · containers

## Symptom
Right after the second monitoring platform went fleet-wide, nearly two dozen hosts fired the same "load average too high" alert within seconds of each other, all at almost the same value regardless of what each host was doing.

## Investigation
Identical values across very different hosts pointed to a structural cause, not a per-host one. Compared the monitoring platform's per-host numbers directly against the hypervisor's own `uptime` output. They matched.

## Root cause
Unprivileged Linux containers share the host kernel, and the standard load-average figure isn't containerized. Every container was reporting the **physical hypervisor's** system-wide load, while correctly reporting its own separately namespaced CPU count.

## Fix
Disabled the duplicate per-container load checks and kept the one accurate check on the hypervisor's own monitoring entry, instead of raising thresholds to silence alerts that never meant anything per host.

## Lesson
When many hosts alarm with the same number at the same moment, suspect the measurement before the hosts.
