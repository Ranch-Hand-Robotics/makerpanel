---
title: Power Panel
category: Power
description: >-
  MakerPanel with selectable paired powerCON, IEC C14, or keyed Anderson
  Powerpole cutouts, adapted from rear-interface connector geometry.
---

# Power Panel

[PowerPanel.scad](PowerPanel.scad) adapts rear-interface connector designs
into a flat MakerPanel; see the source credit below.
It follows the [vent panel](../vent_panel/README.md) example structure and
uses the shared MakerPanel outline and mounting holes. No deck geometry,
rear rail, or dependency on an external deck checkout is included.

## Customization

- Set `type` to `Neutrik powerCON`, `AC Computer Power cable` (IEC C14),
  or `Anderson Powerpole`.
- Adjust `horizontalPitch`, `verticalUnits`, and `panelThickness`.
  The default is **20 HP × 1U**, or **101.6 × 44.45 × 3 mm**.
- The powerCON option retains two 24 mm nominal body openings, 42 mm
  center spacing, and diagonal flange holes on a 24 × 19 mm pattern.
- The IEC C14 option retains a 27.5 × 20 mm nominal opening with 1.5 mm
  corner radii and mounting holes spaced 40 mm apart.
- `connectorClearance` adds 0.4 mm to the powerCON/IEC opening dimensions
  and the nominal 3.2 mm connector mounting-hole diameter.
- The Powerpole option retains a 16 × 8 mm bonded-pair opening and a
  dovetail key on its +X side. Its separate `powerpoleFitClearance` adds
  0.15 mm per side. It has no connector screw holes or retention bracket.
- Each connector's dimensions and spacing remain independently adjustable.
  Changing panel size does not scale the connector cutouts.

## Outputs and mounting

- `part = "makerpanel"`: the 3D panel, flat on Z = 0.
- `part = "panel_2d"`: the same outline and cutouts for SVG/DXF export.

The panel is centered in XY, with all openings cut through its thickness.
The former rear-panel vertical axis is now panel Y. The MakerPanel library
provides four 3.5 mm mounting holes inset 5.5 mm from adjacent edges.
As with `vent_panel`, keep the repository's `makerpanel` library available
on the OpenSCAD library path.

## Fabrication notes

Verify dimensions against the exact connector manufacturer's drawing and
test the fit before fabrication. Maintain at least 2 mm of material at
edges, avoid overlap with the panel mounting holes and rails, and allow
space for connector flanges, terminals, insulation, and cable bends.
The library uses nominal U spacing for panel height; 3U produces 133.35 mm,
not the specification's 128.5 mm standard 3U faceplate.

These are mechanical cutout templates, not an electrically certified
assembly. Mains-powered builds require suitably rated connectors,
enclosures, materials, grounding where applicable, and strain relief.
The original Powerpole opening assumes bonded housings and adhesive
retention; assess retention and electrical safety for the intended use.

## Attribution and license

Connector geometry is adapted from Ranch Hand Robotics'
[source project](https://github.com/Ranch-Hand-Robotics/deck_nomad), specifically
the `designs/cyberdeck.scad` rear-interface modules. Changes replace the deck's
rear wall and placement transforms with an HP/U MakerPanel and expose
the extracted dimensions through the Customizer.

This adapted design retains the source project's
[CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/).
It is provided as-is, without warranties. The shared MakerPanel library
retains its own license.