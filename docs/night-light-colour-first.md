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

Dashboard follow-up: replaced 36 retired kitchen-light references across the
Overview and touch dashboards, including individual cards, group controls and
the offline indicator. All dashboard configurations were checked afterward and
contained no retired kitchen references. Supported configuration API save/readback
verified both updates; private backups support rollback. No physical light test
or restart was required. Browser rendering was not inspected.

The complete integration is now published as
[ha-ewelink-lan-light](https://github.com/axw13/ha-ewelink-lan-light), after explicit
operator authorization and another review of source, all historical file versions,
author metadata and releases. No live secret matches or personal infrastructure
inventory were found; staged and full-history secret scans passed. Public access
was verified without authentication. Release v0.3.4 includes HACS custom-repository
installation instructions, tested bulb hardware/firmware details and a local
credential/provisioning guide using placeholders. Personal runtime settings and
firmware dumps are excluded. Publication did not change the live installation.
