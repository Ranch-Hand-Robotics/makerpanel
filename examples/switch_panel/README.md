---
title: Switch Panel
category: Digital I/O
description: >-
  MakerPanel for Guarded Switchs.
---

# Switch Panel

[switch_panel.scad](switch_panel.scad) generates a panel around a row of
switch openings, accounting for the control layout and rail clearances.

## Customization

- Set `switch_count` for the number of switches.
- Set `switch_hole_diameter` and `switch_spacing` from the actual hardware.
- Adjust `verticalUnits` and inspect the resulting panel width.

Confirm clearance for switch bodies, nuts, terminals, and wiring behind the
panel. This mechanical design does not specify wiring or electrical ratings.