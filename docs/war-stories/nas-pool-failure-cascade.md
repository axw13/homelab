# Multi-day, multi-drive NAS pool failure cascade

**Area:** storage · ZFS · hardware

## Symptom
Several drives in the NAS pool started failing over a number of days. It ended in a severe pool suspend that corrupted several VM/container disk images at once and pushed hypervisor load into the triple digits.

## Investigation
- Several drives were genuinely bad. One apparent "second failure" wasn't: a failing drive's bus noise was disrupting a healthy neighbour on the same expander channel.
- Isolated by pulling the actual bad drive and confirming the neighbour's symptoms cleared.
- The load spike traced to every process being stuck in uninterruptible I/O wait on the suspended storage mount.

## Root cause
Multiple real drive failures, made worse by one failing drive disturbing a healthy one on a shared channel, ending in a pool suspend. Workloads with heavy I/O were sitting on the shared NAS storage that suspended.

## Fix
- Rebuilt the pool from scratch, deliberately trading capacity for reliability instead of recreating the original larger layout.
- Moved the highest-I/O workloads off shared NAS storage entirely, onto local SSD.

## Lesson
A symptom on one drive can come from its neighbour. Confirm by removing the suspect, not by replacing everything that looks unhealthy. After recovering, remove the failure mode (shared storage under hot workloads) rather than just restoring the previous layout.
