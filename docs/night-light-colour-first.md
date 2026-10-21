# Lighting colour before power

The operator requested colour preparation before power-on for a night light and
then for the normal entrance/kitchen rule. The installed integration always sent
power-on before colour, so splitting ordinary light actions did not change order.

Added an opt-in colour-only entity action using Home Assistant's
[entity-service helper](https://developers.home-assistant.io/docs/dev_101_services/).
It validates exactly one of RGB or colour temperature plus brightness, sends no
power command, and preserves the power-state flag. The night rule prepares green
at 2% brightness; the normal rule prepares three bulbs at 6500 K white and 100%.
Each then sends a separate power-on action. Default combined action behavior is
preserved; existing motion conditions and shutdown deadlines remain in place.

Configuration checking, registered-service checks, automation validation and
exact save/readback verify the deployed configuration. Seven mocked transport
tests cover RGB/white command order, no false power state, failure handling,
invalid colour choices and preservation of the default combined action.

No physical light command was issued as a test. Optimistic state and firmware
acceptance of colour while off limit what software checks prove; physical startup
appearance needs observation in normal use. Backups and source overlays support
rollback without replacing other integration files. Future integration updates
must preserve the action or revert its callers.
