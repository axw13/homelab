# The watchman that counted ghosts - and missed a real outage

**Area:** monitoring · AI-assisted fleet maintenance

## Symptom
The daily "watch the watchman" report went critical: the alert dispatcher (the job that turns new monitoring alerts into tracked issues for the maintenance agents) had not checked in for 87 hours, and there were "6 open problems, alerts likely suppressed". Four of those problems were things the owner knew to be fine: a DHCP service that was running, a NAS "memory above 90%" warning, and two storage pools reported offline that were healthy.

## Investigation
- The dispatcher's cron entry was still present - but commented out with a marker left by an earlier maintenance window (a security-platform upgrade). The upgrade had finished days before; the three frequent maintenance jobs had simply never been switched back on.
- For the "ghost" problems, every trigger involved was **disabled** - they had been switched off weeks earlier as known false alarms. The current item values even said OK (memory at 71 %, pools ONLINE).
- The monitoring platform keeps a problem open when its trigger is disabled, and the report counted every open problem regardless of whether anything still evaluated it.

## Root cause
Two separate gaps: a maintenance pause with no "undo" step, and a report that treated frozen problems of disabled checks as live alerts - so real noise and fake noise looked the same.

## Fix
- The paused jobs were restored and their heartbeats confirmed.
- The report now counts only problems of enabled triggers on monitored hosts, and only unsupported items that are actually monitored.
- The storage-pool checks were re-enabled (they were correct; the old problems closed at the next value). The memory check stays off - a ZFS box uses spare RAM as cache, so "90 % used" is normal - and so does the DHCP check, whose data source never delivers.

## Lesson
Every pause needs its own undo, checked in the same session. And a report is only as good as its definition of "open": a disabled check should disappear from the count, not stay red forever.
