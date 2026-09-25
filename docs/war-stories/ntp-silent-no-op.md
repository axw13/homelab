# A fleet-wide NTP change that silently did nothing

**Area:** Linux · containers · time sync

## Symptom
A fleet-wide NTP configuration change reported success on every container, but nothing was actually happening.

## Investigation
Checked whether the time-sync service was really running and adjusting clocks inside the containers. It wasn't: the service refused to even start in a container.

## Root cause
Unprivileged Linux containers share the host kernel's clock. They can't run their own time-sync client, and they have no permission to adjust the clock anyway.

## Fix
Pointed the **hypervisor's** clock at the new internal time server. Every container inherits it for free.

## Lesson
"The task reported success" and "the task did something real" are two different claims, especially for anything kernel-level.
