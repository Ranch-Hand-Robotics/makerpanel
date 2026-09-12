---
title: Keyboard Layout Components
category: Digital I/O
description: >-
  Cherry MX switch, stabilizer, and keycap geometry for keyboard layout
  prototyping, plus a Kinst MF34-inspired keycap arrangement.
---

# Keyboard Layout Components

This folder contains reusable keyboard geometry rather than a finished
MakerPanel mounting plate.

## Design files

- [cmx.scad](cmx.scad): Cherry MX switch footprints, stabilizer geometry,
  and keycap primitives for plate and layout experiments.
- [kinst_mf34.scad](kinst_mf34.scad): the `kinst_mf34()` module, which places
  keycaps using the local Cherry MX library. This file defines a module;
  call it from a host design to display the layout.

The arrangement is reference geometry, not a verified reproduction of the
physical MF34 keyboard. Confirm key count, spacing, stabilizers, and PCB
alignment before using it to design a mounting plate.