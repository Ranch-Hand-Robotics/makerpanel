---
title: Measurement Gauge
category: Tools
description: >-
  Printable MakerPanel, MakerRail, and rack measurement references with raised
  ticks and labels for checking dimensions and mounting positions.
---

# Measurement Gauge

[measure.scad](measure.scad) generates dimensional reference tools for
planning and checking modular panel assemblies.

## Customization

- Select `part = "makerpanel"` for the 3D panel measuring reference,
  or `part = "rail"` for the rail gauge.
- The existing `rack` option is reserved but currently calls an undefined
  `rack_ruler()` module; it does not produce a rack gauge.
- Set `horizontalPitch` and `verticalUnits` for the desired span.
- Review `rack_type` when generating a rack gauge.

Check the printed gauge with calipers before relying on it: printer scaling,
material shrinkage, and layer quality affect its accuracy. It is a workshop
reference, not a calibrated measuring instrument.