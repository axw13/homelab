# Migrating the smart-home fleet onto its own IoT VLAN

**Area:** networking · home automation

## Problem
A dozen-plus smart-home devices had to move off the general clients segment onto a dedicated IoT VLAN. They used five different local/cloud protocols (WLED, ESPHome, local Tuya, cloud Tuya, a manufacturer camera app), each with its own migration path.

## Recurring gotcha
Several local-protocol devices got a **new authentication key** from the vendor's cloud the moment they rejoined on the new network. Same physical device, same account, but the stored local credential silently stopped working.

## Investigation
One stubborn device was on a locked-down cloud account with no in-app way to view its key. Dead ends along the way:
- The vendor's developer cloud API was blocked by an unexplained subscription-entitlement error, on two separately created projects.
- A MITM-based key extraction was blocked by the very network segmentation this migration was putting in place.

## Fix
The vendor's own web console had a session-authenticated API explorer. It doesn't use the developer-credential path, so it bypassed the entitlement gate and exposed the key.

## Lesson
Re-joining a network can change more than an IP address. When the official route is blocked, look for another first-party interface that authenticates differently.
