# "Everything is offline" after a power outage

**Area:** home automation · DHCP

## Symptom
After a power outage, about a dozen unrelated Home Assistant integrations were broken at once.

## Investigation
Looked for one shared cause instead of fixing each integration separately.

## Root cause
Most local-network integrations store a device's IP once and never notice when its DHCP lease changes. After the outage, devices came back on new addresses and the integrations were still pointing at the old ones.

## Fix
Fixed the underlying cause once rather than patching each symptom individually.

## Lesson
When many unrelated things fail together, look for the one thing they share: here, an addressing assumption none of them checked.
