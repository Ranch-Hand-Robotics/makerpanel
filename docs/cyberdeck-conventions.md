# Shared cyberdeck configuration conventions

Use this contract when creating or changing MakerPanel-based deck hosts.
The goal is consistent names, choices, visibility, and behavior across
projects, not identical deck geometry. Read the reference implementation
before adding a control; do not invent a second interface for the same job.

## Provenance and scope

Extracted September 22, 2026 from `deck_nomad/designs/cyberdeck.scad`:
the Customizer declarations, `cyberdeck_top_rail_total_t()`,
`cyberdeck_top_rail_metal_t()`, `cyberdeck_part_token()`, and printer guide.
Riptide adopts the contract in `designs/riptide.scad`.

The user's explicit rule supersedes older preview options in Nomad:
**chunking is export machinery, not a user-facing configuration workflow**.
Do not copy every control from a reference file just because it exists.
In particular, Nomad currently places rail/printer tuning after `[Hidden]`;
range comments do not make those assignments visible. Other entrypoints
have not automatically been migrated by publication of this guide.

This is a deck-host interface convention, not a replacement for the
[mechanical specification](specification.md) or [MakerStack API](makerstack.md).
Do not change library parameter names merely to match a Customizer label.

## Public choices versus implementation details

- Use `[Part Selection]` for `part` and necessary product selectors.
- Use `[Cyberdeck Parameters]` for meaningful deck choices: case, equipment,
  layout, tier pitch, and `maker_rail_type` where supported.
- When bed dimensions are requested in the UI, use `[Printer]` and the three
  established scalar names below. This deliberately promotes Nomad's hidden
  dimensions; it does not introduce a competing vector setting.
- Keep derived geometry, margins, tolerances, joint tuning, diagnostic
  flags, and guide-position tuning under `[Hidden]`.
- No `slice_source`, `chunks`, chunk-coordinate sliders, exploded chunk
  layouts, or packing-gap controls in the public UI. The selected export
  already identifies its source. Do not keep obsolete UI names as aliases.
- Read the entire active Customizer section when reviewing visibility.
  A numeric range or enum annotation alone is not evidence of exposure.

## Printer contract

| Name | Standard default | Meaning |
| --- | --- | --- |
| `printer_guide_w` | 320 mm | Usable printer X span |
| `printer_guide_h` | 320 mm | Usable printer Y span |
| `printer_guide_d` | 325 mm | Usable printer Z span |
| `printer_guide_enabled` | false | Diagnostic build-volume display |
| `printer_guide_x` | 50 mm | Guide center X, not build width |
| `printer_guide_y` | 100 mm | Guide center Y, not build depth |
| `printer_guide_z` | 0 mm | Guide center Z, not build height |
| `middle_frame_chunk_edge_margin` | 6 mm | Hidden per-edge allowance |

Use the same dimensions for partitioning and the guide. A local vector
expression passed to a helper is fine; a second independently configurable
`printer_bed` is not. Guide placement must not move parts or change slicing.
References belong outside manufacturing booleans and outputs. Nomad uses a
background cube; an embedded renderer may require an assembly-only debug
reference instead. Document that distinction rather than relying on
`$preview` or a screenshot alone to prove export exclusion.

Reserve joint projection in the printable envelope. Orientation and seam
placement depend on the part; do not copy Nomad's upright rotation into a
flat case adapter. Check all three printer axes after orienting the part,
and normalize each exported part to its own bed datum. Do not imply that
XY splitting handles over-height Z parts.

## MakerRail material contract

Use **`maker_rail_type`**, with the exact choices **`3D Printed`** and
**`Laser Cut`**. Do not replace the choice with a metal-thickness slider
whose zero value secretly selects the manufacturing process.

Both modes have a printed rail integrated into the supporting frame.
`Laser Cut` adds a bonded metal top over the printed backing; it does not
remove the backing or require a detached printed cap.

Keep the established engineering settings hidden:

| Name | Reference default | Meaning |
| --- | --- | --- |
| `top_maker_rails_full_h` | 3.5 mm | Minimum finished stack height |
| `top_maker_rails_metal_t` | 2.0 mm | Intended bonded metal thickness |
| `top_maker_rails_printed_min_t` | 2 mm | Minimum printed backing |
| `show_maker_rails` | true | Show optional metal in assembly only |

For nonnegative settings, total height is the greater of `full_h` and
`metal_t + printed_min_t`, **in both modes**. Printed mode uses that entire
height in plastic; laser mode replaces its upper `metal_t` with metal.
Default total height is therefore 4 mm, with either 4 mm printed or
2 mm printed plus 2 mm metal. Switching material must not move panel seats,
nut datums, column shoulders, or the fitted tier count.

Nomad's `maker_rails_thickness` is a separate sheet/nesting setting;
`sheetmetal_thickness` belongs to its structural sheet/splines. Neither is
the finished top-rail stack height. Do not copy unrelated outer-rail or
sheet-nesting controls into a deck that has no such feature.

Use canonical MakerPanel slot geometry and a shared outline for printed
backing and metal. Visibility flags must not remove printed structure,
change the material mode, or suppress a requested manufacturing export.
Adhesive thickness and physical bond qualification remain separate concerns.

## Manufacturing export contract

- `assembly` is contextual, not a print-ready manufacturing output.
- Use `maker_rails_2d` for the matching top metal outline. Like Nomad, emit
  no metal-cut geometry in `3D Printed` mode; a message is appropriate.
- One token ending in `MxN` represents each host-expanded part array.
  Product-specific prefixes are appropriate; do not enumerate coordinates
  in the dropdown or force unrelated decks to use the same part names.
- The host supplies concrete indices. A literal template may preview
  `[0,0]` without exposing index controls. Malformed, fractional, negative,
  or out-of-range indices must be empty, never clamped or substituted.
- Compact occupied cells if required by the host's empty-output termination
  contract; document how indices map to geometric cells.
- Extract from canonical assembled geometry, retaining mounting holes,
  voids, channels, and joins. Never independently redraw a simplified part.
- Glue dovetails must widen beyond their root and have matching sockets.
  Do not hide incorrect joins with overlapping parts or displaced seams.

## Adoption and review checklist

1. Compare the reference's actual declarations **and consumers**, including
   the active section, units, default, enum/range, and export behavior.
2. Reuse an existing concept's name and meaning. Document any justified
   product-specific difference; get agreement before redesigning the UI.
3. Keep shared library geometry/APIs independent of host UI. Put thin
   parameter mapping in the host instead of forking the rail implementation.
4. Test public controls as an interface: no debug/chunk settings leaking
   above `[Hidden]`, no duplicate source selectors, and stable enums.
5. Check both material modes, a smaller bed, valid and invalid exports,
   datum invariance, and exclusion of guide/case/fan references.
6. Use the repository's embedded OpenSCAD renderer. Distinguish compilation,
   sampled connectivity, mesh manifoldness, and physical qualification.

Keep this guide in the shared MakerPanel dependency. Each consuming deck
should have a short `.github/instructions/*.instructions.md` that points
to its checked-out copy, rather than maintaining a divergent standards
document. Update this contract before introducing a new shared convention.