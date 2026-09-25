# Media-server freezes caused by five other services

**Area:** performance · storage · observability

## Symptom
The media server kept freezing during playback.

## Investigation
- **A first plausible fix:** hardware transcoding was misconfigured despite a working GPU. That was a real bug worth fixing but not the cause: the session that froze wasn't using video encoding at all.
- **Host-level metrics** showed dozens of processes permanently stuck waiting on disk I/O, and a load average several times the core count, on two budget DRAM-less consumer SSDs that back every container's storage.
- **Ranking every container by cumulative disk reads** showed the pattern: five independent services (workflow automation, an uptime monitor, the secondary monitoring stack, the SSO provider, a home-inventory app) had each been piling up unbounded history/log/execution data with no pruning.

## Root cause
No single culprit. Each service's data was only a few hundred megabytes, but together they generated constant heavy reads against already-weak disks.

## Fix
Fixed each service at its source:
- turned on built-in retention/pruning where it existed
- corrected an auto-discovery template default where the platform exposed no setting
- added a scheduled cleanup job where no config option existed at all
- deleted stray leftover files that weren't real data

## Lesson
The service showing the symptom often isn't the one causing it. Contention from many small, reasonable-looking sources is harder to spot than one obviously misbehaving process.
