---
title: Ventilation Panel
category: Other
description: >-
  Ventilation MakerPanel.
---

# Ventilation Panel

[VentPanel.scad](VentPanel.scad) creates a configurable vented MakerPanel.
The nested `IsoGridScad` directory is a supporting library, not this example's
main design.

## Customization

- Set `type` to `Holes`, `Honeycomb`, or `Isogrid`.
- Choose `fan` for optional fan mounting geometry.
- Adjust `horizontalPitch`, `verticalUnits`, `gridScale`, and `inset` for
  the panel size and pattern.
- Enable `fingerHole` when an access opening is useful.

Keep the IsoGridScad dependency available when rendering. Check the chosen
fan's mounting pattern and blade clearance, and assess airflow and panel
stiffness for the intended application; neither is certified by the geometry.