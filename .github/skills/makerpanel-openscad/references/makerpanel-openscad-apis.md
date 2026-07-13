# MakerPanel OpenSCAD APIs (Repository Reference)

Use this reference when implementing MakerPanel-compatible geometry.

## Canonical Standards Document
- Specification source of truth: [`docs/specification.md`](../../../../docs/specification.md)

## Unit & Constants API (`makerpanel/common.scad`)
Source: [`makerpanel/common.scad`](../../../../makerpanel/common.scad)

- `function hp_to_mm(hp)`
- `function u_to_mm(u)`
- `function u_clear_to_mm(u)`

Common constants used by project geometry include:
- `HP`, `U`
- `T_SLOT_HEIGHT`, `T_SLOT_WIDTH`, `T_SLOT_CORNER_RADIUS`
- `RACK_SUPPORT_WIDTH`, `RACK_HOLE_DIAMETER`, `RACK_RAIL_HEIGHT`, `RACK_RAIL_THICKNESS`
- `PANEL_THICKNESS`, `PANEL_DEPTH_MAX`, `MOUNT_HOLE_DIAMETER`

## Panel API (`makerpanel/panel.scad`)
Source: [`makerpanel/panel.scad`](../../../../makerpanel/panel.scad)

- `module makerpanel_2d(width_hp, height_u, mount_hole_diameter=MOUNT_HOLE_DIAMETER)`
  - 2D panel profile with mounting holes.
- `module makerpanel(width_hp, height_u, thickness=PANEL_THICKNESS, mount_hole_diameter=MOUNT_HOLE_DIAMETER)`
  - 3D panel via linear extrusion.

## Rail API (`makerpanel/rails.scad`)
Source: [`makerpanel/rails.scad`](../../../../makerpanel/rails.scad)

- `module rounded_square(size, r=1)`
- `module maker_rail_2d(rail_width, height, mounting_holes=true, base=true)`
  - 2D rail profile with T-slot cutouts.
- `module maker_rail(rail_width, height=RACK_RAIL_HEIGHT, depth=RACK_RAIL_THICKNESS, mounting_holes=true)`
  - 3D rail extrusion.
- `module makerrack_custom(width, height)`
  - Custom-width rack side rail layout.

## Rack Adapter API (`makerpanel/rack.scad`)
Source: [`makerpanel/rack.scad`](../../../../makerpanel/rack.scad)

- `module obround_slot_2d(length, diameter)`
- `module rack_mount_holes_2d(rack_u, hole_c2c, slot_len=8, hole_d=6.5)`
- `module rack_faceplate_2d(rack_u, outer_width, hole_c2c, center_clearance)`
- `module rack_19(rack_u)`
- `module rack_10(rack_u)`

## Usage Guidance
1. Prefer these modules/functions over duplicating base geometry.
2. Keep dimensions parameterized in mm but expose HP/U-facing controls where relevant.
3. Validate changed geometry against MakerPanel specification requirements (mounting compatibility, depth limits, and clearances).
4. When source constants and spec text diverge, flag the mismatch in your summary and avoid silent reinterpretation.
