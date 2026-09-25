# A WireGuard peer whose replies vanished

**Area:** VPN · routing · NAT

## Symptom
A new WireGuard remote-access peer could send traffic out through the tunnel, but every reply was lost, DNS included.

## Investigation
Ran a live packet capture on the gateway's own interface during a real connection attempt. That separated two failure modes that look identical from the client:
- traffic never arrives (a port-forward/NAT problem upstream)
- traffic arrives but has no route back (this bug)

## Root cause
The gateway's outbound NAT rule for tunnel-peer traffic didn't exist. The router had no route back to an individual peer's tunnel address; only the gateway host's own address was a known route on that segment.

## Fix
Added the missing outbound NAT rule for tunnel-peer traffic.

## Lesson
Pick a test that tells failure modes apart. A capture at the right hop tells you which half of the path is broken.
