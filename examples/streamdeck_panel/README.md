---
title: Stream Deck Module Panel
category: Digital I/O
description: >-
  Tild MakerPanel mount for 6-, 15-, or 32-key Stream Deck OEM modules.
---

# Stream Deck Module Panel

[streamdeck_panel.scad](streamdeck_panel.scad) integrates a Stream Deck
module into a MakerPanel using a sleeve and separate bolted rear retainer.

## Customization

- Choose `module_type` for the `6_key`, `15_key`, or `32_key` module.
- Set `tilt_angle`, `horizontalPitch`, and `verticalUnits` for the layout.
- Use the `part` selector to inspect the assembly and individual components.

The 15-key retainer includes clearance for rear module tabs. Check your exact
module revision, tab placement, cable access, and fastener lengths before
fabrication. This is a module mount, not a guaranteed fit for a complete
retail enclosure.

The bottom retaining face is recessed **3 mm forward into the top sleeve**
along the tilted device axis (`rear_seat_recess`). This compensates for the
tab-inclusive depth without changing the top plate, flange mating plane,
or bolt pattern. The original 0.2 mm seating allowance remains; on the
15-key module the bearing face is now at local Z = **−10.2 mm**.

The four bottom-only tab openings are **6 × 9 mm** in X/Y, with 2 mm
clearance per side. They extend from local Z = −18.3 to −9.7 mm so the
recessed seat cannot cap them. Re-export only the `bottom` part; the existing
top plate does not need replacement. Confirm the fit before tightening.