---
title: Iris Keyboard Panel
category: Input
description: >-
  Panel for an Iris split keyboard.
---

# Iris Keyboard Panel

[IrisMakerPanel.scad](IrisMakerPanel.scad) adapts an Iris keyboard cutout to
a MakerPanel. The design provides flat cutting and extruded panel geometry.

## Customization

- Select `part = "makerpanel"` for one 3D mounting/measuring panel,
  `assembly` for the mirrored pair, or `iris_keyboard_laser` for 2D export.
- The assembly's primary panel shares the standalone panel's origin. Its
  mirrored companion is one panel width along +X; the pair is not centered.
- Set `horizontalPitch` and `verticalUnits` for the surrounding panel.
- Adjust `keyboard_cutout_offset_x` and `keyboard_cutout_offset_y` to position
  the keyboard opening.
- Keep the referenced SVG files alongside the design when rendering.

Check the opening against your Iris revision, switch plate, and PCB before
cutting or printing. The mirrored assembly is a layout preview, not a complete
electronics model.