---
title: Joystick Control Panel
category: Analog Control
description: >-
  Panel for one or more SaiDian 4 Axis Joystick Components.
---

# Joystick Control Panel

[design/joystick.scad](design/joystick.scad) uses a SaiDian 4-axis mini
joystick as its reference control and generates the surrounding panel.

## Customization

- Set `joystickCount` to select the number of joysticks.
- Enable `e_stop` to add the button opening and set `e_stop_diameter` to fit.
- Adjust `verticalUnits` and inspect the calculated panel width and clearances.

Measure the actual joystick and button before fabrication. The optional
emergency-stop feature is a mechanical opening only; it does not implement
or certify a safety circuit.