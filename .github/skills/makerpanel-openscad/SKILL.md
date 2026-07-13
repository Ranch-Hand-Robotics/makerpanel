---
name: makerpanel-openscad
description: 'Design or modify MakerPanel/OpenSCAD geometry using MakerRail APIs and MakerPanel standards. Use for panel sizing in HP/U, rail generation, rack adapters, bent arms, and spec-compliant mechanical checks.'
argument-hint: 'What OpenSCAD change do you need (panel, rail, rack, or accessory geometry)?'
user-invocable: true
---
# MakerPanel OpenSCAD Design Workflow

Build and edit OpenSCAD geometry for MakerPanel/MakerRail systems while treating the project specification as the source of truth.

## When to Use
- Editing `*.scad` files for MakerPanel-compatible geometry.
- Adding configurable dimensions/angles (for example, articulated arms, brackets, adapters).
- Building panel/rail/rack geometry with project APIs instead of one-off primitives.
- Reviewing whether geometry follows MakerPanel standards in `docs/specification.md`.

## Source of Truth Rule
1. Use [`docs/specification.md`](../../../docs/specification.md) as the authoritative standard.
2. Use OpenSCAD APIs in [`makerpanel/common.scad`](../../../makerpanel/common.scad), [`makerpanel/panel.scad`](../../../makerpanel/panel.scad), [`makerpanel/rails.scad`](../../../makerpanel/rails.scad), and [`makerpanel/rack.scad`](../../../makerpanel/rack.scad) to implement that standard.
3. If implementation constants appear to differ from the spec, preserve compatibility in code changes and explicitly call out the mismatch for maintainer review.

## OpenSCAD Customizer Conventions (Recommended)
- Expose user-facing controls under `/* [Customization] */` and implementation details under `/* [Hidden] */`.
- Prefer MakerPanel-native sizing controls in Customizer:
   - `horizontalPitch` (HP-based panel width)
   - `verticalUnits` (U-based panel height)
- Provide a `part` selector for focused rendering/export, following repo patterns:
   - Example: `part = "assembly"; // [assembly, panel, rail, bracket]`
   - Use `if/else` part dispatch at file end to render the selected module.
- Keep `part` option names short and stable so users can script exports consistently.
- When practical, include a default `assembly` option plus individual manufacturable parts.

## Procedure
1. **Read context first**
   - Open the target SCAD file and inspect includes/transforms.
   - Load API reference: [MakerPanel OpenSCAD APIs](./references/makerpanel-openscad-apis.md).
2. **Map requirements to APIs**
   - Unit conversions: `hp_to_mm()`, `u_to_mm()`, `u_clear_to_mm()`.
   - Panel bodies: `makerpanel_2d()`, `makerpanel()`.
   - Rail generation: `maker_rail_2d()`, `maker_rail()`, `makerrack_custom()`.
   - Rack adapters: `rack_19()`, `rack_10()` and rack helpers.
3. **Implement parameterized geometry**
   - Prefer named variables/functions over hard-coded transforms.
   - Expose HP/U controls in Customizer where relevant (`horizontalPitch`, `verticalUnits`).
   - Add/maintain a `part` Customizer selector and part-dispatch block for assembly vs single-part rendering.
   - Keep existing coordinate conventions unless change is required and documented.
   - For multi-segment shapes, define intermediate joint functions and endpoint functions.
4. **Apply standards checks**
   - HP/U sizing aligns with spec intent.
   - Mounting strategy remains T-slot compatible (M5/M6 nut ecosystem).
   - Depth/clearance assumptions are documented when relevant.
5. **Validate and report**
   - Run diagnostics/syntax checks after edits.
   - Summarize changed parameters, geometric behavior, and any spec/code discrepancies.

## Decision Points
- **Need standard panel geometry?** Use `makerpanel()` rather than rebuilding panel rectangles manually.
- **Need rail cross-section or extrusion?** Use `maker_rail_2d()` / `maker_rail()` and tune parameters.
- **Need 10\" or 19\" adapter faceplate?** Use `rack_10()` / `rack_19()`.
- **Need custom accessory geometry?** Compose with hull/boolean ops, but keep mounting points aligned to MakerPanel/MakerRail dimensions.

## Completion Criteria
- Geometry is parameterized and readable.
- Uses project APIs where applicable.
- Customizer includes HP/U-oriented controls when applicable.
- `part` selector exists for assembly and individual part previews/exports when applicable.
- No new SCAD diagnostics.
- Output clearly states what changed and why.
- Any spec-vs-code dimension mismatch is explicitly noted.
