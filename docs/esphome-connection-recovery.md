# Recovering ESPHome controls after DHCP changes

Devices were running and their builder logs worked, while their Home Assistant
controls and sensors remained unavailable. The integration retained previous IP
addresses after the devices received permanent DHCP reservations.

The investigation compared stored integration hosts with the builder's current
addresses, checked existing reservation MACs, and tested native API connectivity
from Home Assistant's own network path. Old endpoints were unreachable; current
ones accepted TCP connections. Existing encryption keys already matched.

Home Assistant's supported ESPHome setup flow authenticated each current endpoint,
matched the existing device identity and updated the existing entry. There was no
firmware upload or full Home Assistant restart. All 12 enabled ESPHome entities
recovered, with live blind position/calibration and environmental readings.
Physical controls were not actuated merely to test the repair. Entity identities,
dashboards and automations were retained.

A config entry can report loaded while its asynchronous device connection is
unavailable. Device/entity state and a real API handshake are stronger evidence
than setup status alone. Buttons may normally report unknown because they lack a
persistent on/off state; their last-pressed timestamps must not be interpreted as
binary restart-required counters in monitoring.

For REST reconfiguration, initialize the config flow with the integration handler
and a top-level existing entry_id, then submit the host/port to that flow. Nesting
entry_id inside context does not select reconfiguration at this endpoint.

The native API connection is described in the official
[ESPHome integration documentation](https://www.home-assistant.io/integrations/esphome/).
The flow endpoint behavior is defined by
[Home Assistant's config-entry implementation](https://github.com/home-assistant/core/blob/2026.9.4/homeassistant/components/config/config_entries.py).

The accompanying remediation follow-up verified a repaired shared AI-bridge
credential alias with an actual generation request. Subsequent nightly MEGA
uploads completed in 3m29s and 5m02s with accepted backup success heartbeats;
these are upload timings rather than total job durations. Incident verification
continues without AI calls, including live package-count checks for an item whose
unchanged stored value has a twelve-hour heartbeat.
