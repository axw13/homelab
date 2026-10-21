# Migrating lighting automations between integrations

After replacing a lighting integration, matching friendly names did not preserve
the entity IDs used by existing automations. The old entities were unavailable;
the replacement entities exposed the expected brightness and colour capabilities.

Updated eleven references across normal motion lighting, night lighting and an
away shutoff automation. A reverse mapping reproduced each original configuration
exactly, verifying that only the intended entity references changed. Sensor,
timer, brightness, time/lux and unrelated device actions were preserved.

All three configurations passed Home Assistant validation and exact saved-config
readback. A full automation scan found no remaining old kitchen references;
scripts, scenes and old device targets were checked too. Existing enabled states
were retained, including the already-disabled away rule.

No lights were toggled or automations manually executed as a test. The replacement
integration reports optimistic state, so configuration validation does not establish
physical response; a natural control cycle remains the final behavioural check.
