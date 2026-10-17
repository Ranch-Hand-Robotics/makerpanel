---
title: Grid Plate MakerPanel
category: Other
description: >-
  Perforated equipment carrier with configurable grid spacing and optional
  Jetson Nano, Raspberry Pi, and LattePanda mounting patterns.
contributor: Ranch Hand Robotics
---

# Grid Plate MakerPanel

[GridPlate.scad](GridPlate.scad) is a removable, rail-mounted equipment
plate. Use its regular hole grid with separate spacers, or select integral
printed SBC standoffs. It reuses MakerStack's grid and board-pattern helpers
without requiring a stack or case.

Add the repository root to the OpenSCAD library search paths, so that
`<makerpanel/common.scad>` resolves to the bundled library. In the URDF
editor this is the `urdf-editor.OpenSCADLibraryPaths` setting.

## Dimensions and controls

| Control | Default | Meaning |
| --- | --- | --- |
| `horizontalPitch` | 35 HP | Width; 1 HP = 5.08 mm |
| `verticalUnits` | 3U | Height; this library uses U × 44.45 mm |
| `panelThickness` | 3 mm | Plate only, excluding standoffs |
| `gridPitch` | 12.7 mm | 6.35, 12.7, 25.4, 10, 20, or 25 mm spacing |
| `gridHoleDiameter` | 3.4 mm | Through holes for separate spacers |
| `gridMargin` | 6 mm | Minimum grid-hole center inset |
| `sbc` | `none` | `none`, `nano`, `pi`, `latte`, or `all` |
| `standoffHeight` | 6 mm | Height above the plate |
| `standoffDiameter` | 7 mm | Printed post diameter |
| `standoffRelief` | 0.4 mm | Subtracted from board screw diameter |

The default plate is **177.8 × 133.35 × 3 mm**, centered in XY, with its
bottom at Z=0. Selected standoffs extend toward +Z, giving a default total
height of 9 mm. The four canonical 3.5 mm rail holes are inset 5.5 mm from
their adjacent edges; below 1U, the shared panel API uses two side holes.
No independent mounting-hole pattern replaces the canonical panel outline.

The outside 45-degree chamfer begins at Z=1.2 mm, matching other printable
examples. Internal grid holes are not beveled. Thick plates can compromise
the rail-hole edge land; inspect it before printing. Grid holes reserve
2 mm of material around rail holes, 1 mm around standoff footprints, and
at least 1 mm to the chamfered outer edge. An undersized panel omits an
entire SBC pattern with a console message instead of drawing floating posts.

## SBC options

These are the existing MakerStack reference patterns, not newly measured
boards. Confirm all mounting coordinates against your exact board revision.

| Selection | Reference board | Board envelope | Screw diameter |
| --- | --- | --- | --- |
| `none` | General-purpose grid | — | Grid holes: 3.4 mm |
| `nano` | Jetson Nano reference | 100 × 80 mm | 2.5 mm |
| `pi` | Raspberry Pi reference | 85.6 × 56 mm | 2.5 mm |
| `latte` | LattePanda Alpha/Beta reference | 125 × 82 mm | 3 mm |
| `all` | Combined mounting patterns | Same centered patterns | Per board |

`all` is a universal carrier option, **not a placement for three boards at
once**. Unused posts may touch components on a selected board; inspect its
underside or use only that board's pattern. Board mounting coordinates come
directly from the shared library, including its Raspberry Pi reference.
The SBC body, connectors, cooling, and cable clearances are not modeled.

## Outputs and fabrication

- **`makerpanel`**: printable plate and selected integral standoffs. Pilot
  bores are blind at the plate surface; the plate beneath stays intact.
  Nominal pilot diameters are 2.1 mm for Nano/Pi and 2.6 mm for LattePanda.
- **`panel_2d`**: square-edged SVG/DXF profile with the same grid and rail
  holes. Selected SBCs get through holes at their reference screw diameters
  instead of printed posts. Use separate metal standoffs; apply manufacturing
  tolerances for your screws and cutting process. No standoff projections
  are included in this output.

Keep the same settings when comparing these two alternatives. Grid holes
near selected SBC mounts are suppressed in both, preserving mounting land.
Select `none` for an uninterrupted general-purpose grid. Render with the
URDF OpenSCAD preview and export the selected part. No STL is bundled.

## Bill of materials and assembly

- One printed plate, or a suitably fabricated sheet plate.
- Four compatible rail screws and T-nuts (two for a sub-1U panel).
- Four board screws for one selected SBC; match screw length and thread.
- Separate spacers and retaining hardware for the 2D or plain-grid option.

Mount the plate to the rails without overtightening, then install the board.
Test printed pilot holes with your material and fasteners before mounting
electronics. Do not let screws bottom out or contact circuitry. Provide
electrical insulation where needed, especially with a metal plate.
No wiring, electrical components, load rating, or cooling guarantee is
included. Board fit, print strength, hardware access, and rail compatibility
require physical qualification.

## License

MIT, as for the MakerPanel library; see the repository's LICENSE file.