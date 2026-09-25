# Management-network outage during a VLAN migration

**Area:** networking · switching

## Symptom
The management network went down partway through a VLAN migration.

## Investigation
Worked through it layer by layer instead of reflashing or rebooting things:
1. Bond state
2. Physical link state
3. A full ARP-table cross-reference across every VLAN

## Root cause
A switch-port VLAN reassignment made mid-migration.

## Fix
Corrected the VLAN assignment identified by the ARP cross-reference.

## Lesson
When an outage follows your own change, check each layer in order before reaching for a reboot. The data (link state, ARP tables) shows exactly where traffic stops.
