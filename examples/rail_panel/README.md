---
title: MakerRail Rack Faceplate
category: Other
description: >-
  Mount MakerPanels to 10-inch or 19-inch racks.
---

# MakerRail Rack Faceplate

[RailPanel.scad](RailPanel.scad) uses the shared rack library to create a
faceplate or individual rail with rack mounting ears.

## Customization

- Set `rackWidthInches` to `10` or `19`.
- Set `verticalUnits` for a multi-row faceplate, or `0` for one offset-ear
  rail. The source notes that its mate is rotated 180 degrees.
- Select `part = "makerpanel"` for the 3D mounting/measuring part or
  `part = "rail_panel_2d"` for a flat cutting profile.
- Review `panelThickness` for the intended material.

Keep the repository root available as a library search path. Check rack
hole spacing, rail mating, fasteners, and material stiffness before fabrication.