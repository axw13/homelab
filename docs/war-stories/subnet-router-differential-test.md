# Proving a second VPN path actually works

**Area:** VPN · Tailscale · testing

## Problem
Added a second, independent VPN path (a Tailscale subnet router) to reach the management and infrastructure segments, both remotely and from a local workstation that's normally firewalled away from them. It sits alongside the existing WireGuard gateway, not in place of it.

## Checking assumptions
Expected it to need the same manual NAT fix as the [WireGuard case](wireguard-nat-gap.md), so checked before adding one. It didn't: the tool sets up its own return routing as soon as subnet routing is enabled.

## Testing it properly
A naive reachability test passed whether or not the VPN was connected, because an unrelated segment already had a broad "allow everything else" rule. The real test targeted a **different** segment that has an explicit, narrow block rule: the same request failed with the VPN off and succeeded as soon as it was on.

## Lesson
Two similar-looking VPN tools can handle very different things for you, so check instead of assuming. A test that can't fail proves nothing; test against a path that should be blocked.
