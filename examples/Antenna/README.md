---
title: SDR Antenna Panel
category: Connectivity
description: >-
  SMA Antenna pass-through panel for SDR, WiFi, Bluetooth, Lora.
---

# SDR Antenna Panel

[antenna.scad](antenna.scad) creates a panel for routing antenna connections
through a MakerPanel surface.

## Customization

- Choose `sdr_module` or adjust `antenna_count` for your radio setup.
- Set `antenna_hole_diameter` to suit the actual connectors.
- Adjust the panel dimensions and `isogrid_triangle_size` as needed.

The isogrid geometry uses the library in `../vent_panel/IsoGridScad`.
Keep repository dependencies available to the renderer. Verify connector
clearance, mounting dimensions, and cable bend space before fabrication.