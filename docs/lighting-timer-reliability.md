# Preventing motion sensors from indefinitely extending light timers

A kitchen lighting investigation found repeated occupancy changes cancelling
the automation's pending shutoff. The automation used restart mode, so each new
detection reset even its safety timeout. A separate night-light rule waited for
any one sensor to clear and had no timeout.

Both rules now use a single running instance and a fixed deadline. They wait for
all participating sensors to clear, then require ten uninterrupted quiet seconds.
Renewed motion resets the quiet check while preserving the absolute 15-minute
limit. An unavailable sensor does not count as clear. The limit also applies to
continuous genuine occupancy; it is a deliberate safety cap, not a determination
that the sensor is faulty. Existing sensor coverage, lighting settings and lux/time
conditions were retained.

Home Assistant validated both configurations, eight template boundary cases passed,
saved configuration readback matched, and both enabled automations loaded correctly.
The lights remained off during deployment. No lights were toggled, fake sensor
states injected or automations manually triggered to test household devices.
A full natural post-change motion-to-off cycle remained to be observed.
