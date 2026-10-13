# Interpreting Easy Smart switch counters and VLAN membership

A fresh operator-supplied switch configuration can overturn an old topology
diagram. In this case, previously documented WAN-group ports were down, while
the port with received-bad-packet counts carried a native LAN and tagged client
and IoT networks. VLAN membership alone does not identify the attached device. The operator then
confirmed the error-bearing port connects to the firewall; read-only configuration
matched its VLANs to the LAN interface. These counters therefore concern the LAN
trunk, rather than the ISP-facing WAN interface.

TP-Link community reports describe short tagged frames being counted as both
good and bad on some Easy Smart switches. Tagged traffic makes that explanation
plausible, but it must not be assumed valid for every hardware/firmware version.
A cumulative RxBadPkt count does not directly measure loss. Compare observations
over time and correlate with actual interface errors, loss and link negotiation.

A separate configuration issue was found: an access port was an untagged member
of both a native LAN and the IoT VLAN, despite having an IoT PVID. PVID controls
classification of incoming untagged frames; it does not restrict outgoing VLAN
membership. Broadcast traffic from either VLAN can therefore reach the device
without a tag, weakening isolation and potentially exposing it to competing DHCP.
For a dedicated IoT access port, retain only IoT untagged membership and its PVID,
after confirming the attached device and the operator's recovery path.

The updated documentation separates operator-provided observations, historical
wiring and unconfirmed device associations. No switch or firewall settings were
changed as part of the review.

References: [Easy Smart configuration guide](https://www.tp-link.com/au/document/111934/)
and [reported tagged-frame counter behavior](https://community.tp-link.com/en/business/forum/topic/150395).

A later firewall status capture showed clean reported WAN and physical LAN counters but
nonzero cumulative VLAN output-error totals. These must be distinguished from
per-second monitoring rates and from firewall-blocked traffic. Virtual bridge
errors concern a separate software path and cannot directly identify a physical
switch receive fault. No offloading or MTU changes were made without evidence.
See [Netgate's counter definitions](https://docs.netgate.com/pfsense/en/latest/monitoring/status/interfaces.html).

Follow-up: the operator removed the IoT access port from the native LAN VLAN.
It now has exclusively untagged IoT membership, resolving the identified VLAN
isolation concern. The firewall trunk membership is retained. This configuration
correction does not establish the cause of the separate received-packet counter.

Read-only hypervisor checks then found zero loss in a gateway ping and no increase
in physical NIC error/drop counters. A bridge-drop counter rose at roughly one
per second. Header-only capture identified small Realtek control frames from the
switch; the drop increase stopped while a packet-capture listener was present and
resumed after it exited. This supports unhandled control-frame accounting rather
than demonstrated loss of the tested IP traffic, and shows an observer effect in
software counters. The separate switch receive-bad counter remains unexplained.
[Linux statistics documentation](https://docs.kernel.org/networking/statistics.html)
includes unsupported protocols among received packets counted as dropped.
