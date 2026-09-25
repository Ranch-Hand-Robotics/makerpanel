# MakerStack: stacked MakerRail hosts

MakerStack adds vertical tiers to the flat MakerPanel mounting system.
Each tier remains a MakerRail host for ordinary flat MakerPanels, with an
open equipment bay and four corner connections to the tier below.
This guide describes the current implementation, not a proposed architecture.
The joints still require physical qualification; no load rating or
manufacturing-ready claim is implied.

## How the systems fit together

- **MakerPanel** is the removable plate carrying controls or equipment.
  Its dimensions and holes follow the [panel specification](specification.md).
- **MakerRail** supplies the slotted mounting interface and seating plane.
  Its flat through-slots are not an aluminum extrusion's undercut channel.
- **MakerStack** merges the slotted rails into a printed perimeter support.
   An optional bonded metal top reinforces, rather than replaces, the printed
   slotted backing. Upper supports include columns; the base includes feet.
  Loads between tiers pass through supports and columns, not loose panels.
- **Hard Case Stack** combines MakerStack with case-conforming adapters
  and peripheral bridges. It does not redefine the panel interface.

Multiple panel rows in one plane are not multiple stack tiers. Stacking
also does not imply telescoping, collapse, or independent middle-tier removal.
The implemented standalone arrangement uses aligned, equal-footprint tiers.

## Quick start

Open `makerpanel/makerstack.scad` in the MakerPanel repository. In the
Riptide checkout, it is `designs/makerpanel/makerpanel/makerstack.scad`.
See [OpenSCAD models](openscad.md) for general modeling and export guidance.
Keep `common.scad`, `rails.scad`, and `panel.scad` alongside the entrypoint.

1. Start with `part="assembly"`, `frame_width_hp=48`, `panel_height_u=3`,
   `layers=2`, and `layer_pitch_u=1`. These are the source defaults;
   saved Customizer values may override them.
2. Select `panels="none"` to inspect the host, or `panels="top"` to show
   the sample 16HP panel. Sample panels are not equipment-clearance checks.
3. Choose `foot_style="screw"` or `"bond"` for the mounting surface.
   Decide whether the lowest channels should remain open underneath.
4. Inspect `part="joint"` with hardware and driver envelopes visible.
   Check the real screw, nut, and driver before committing to full frames.
5. Select `part="support"`, `base_support=true` for the printed base.
   Set `base_support=false` for each printed upper support with columns.
6. Leave `rail_metal_thickness=0` for complete printed rails. For optional
   reinforcement, select the sheet thickness before exporting supports and
   use `part="top"` for matching laser-cut metal outlines, one per tier.
7. Bond reinforcement only if selected, then assemble from the base upward
   as described below. Increase pitch for equipment or tool access as needed.

For one standalone host, set `layers=1`; no upper tier is required.
Do not export the contextual assembly as a single printable part.

## Dimensions and datums

All dimensions below are millimeters unless labeled HP or U.
`HP=5.08` and `U=44.45`. The current implementation uses a 3U panel outer
span of **133.35 mm**, not an unrelated rack panel's reduced face height.

`frame_width_hp` measures X between side-rail centerlines, not outside width.
`panel_height_u` measures the panel's outer Y span. Front/back rail spacing
is that span minus one nominal rail width: `panel_height_u * U - 11`.

| Default dimension | Value |
| --- | ---: |
| Side-rail center spacing, 48HP | 243.84 |
| Panel outer Y span, 3U | 133.35 |
| Front/back rail center spacing | 122.35 |
| Nominal rail width / total slotted thickness | 11 / 3 |
| Optional metal / minimum printed backing | 0 / 2 |
| Slot opening height | 6.9 |
| Support and cap strip width | 15 |
| Ring outside, X by Y | 258.84 by 137.35 |
| Central opening, X by Y | 228.84 by 107.35 |
| Complete base width, including feet | 275.84 |
| Base seating plane above mounting surface | 25 |
| Upper column shoulder height | 29.45 |
| Seating-plane interval, 1U | 44.45 |

The 15 mm strip is `nut_channel_width + 2 * nut_channel_wall`.
It extends 2 mm on each side of the nominal 11 mm rail. Widening it
reduces the central opening without moving the rail centerlines.
The cap and support share the same inner and outer ring outlines.

### Printed rails and optional metal

The default rail is fully printed: the slotted top occupies Z=-3 to 0 and
is unioned with its support ring and feet or columns as one physical part.
Nut-channel cutters apply only below the backing, preserving slot lips and
ribs. The two printed regions share their exact face, without overlap shims.

`cap` means **total finished slotted rail thickness**, not sheet thickness.
The finished panel seating plane stays at Z=0 for every material choice:

- Printed backing spans `-cap` to `-metal`.
- Optional metal spans `-metal` to 0; no separate sheet exists at zero.
- The support ring runs from `-frame_depth` to `-cap`.
- Channel openings and nut bearing faces are at `-cap`.

`makerstack_rail_total_t(full_t=3, metal_t=0, printed_min_t=2)` returns
`max(0, full_t, max(0, metal_t) + max(0, printed_min_t))`. Nonnegative inputs
give `max(full_t, metal_t + printed_min_t)`. The standalone entrypoint uses
the nominal 3 mm total and a 2 mm minimum backing:

| Metal sheet | Effective total | Printed backing | Closed pocket floor |
| ---: | ---: | ---: | ---: |
| 0 | 3 | 3 | 5 |
| 1 | 3 | 2 | 5 |
| 1.5 | 3.5 | 2 | 4.5 |
| 2 | 4 | 2 | 4 |

Floor values use the default 15 mm frame depth and 7 mm channel depth.
Increasing the total moves channels, guides, and displayed nuts downward;
it does not move panel seating planes, column shoulders, or screw seats.
Recheck screw engagement and remaining floor material when increasing it.
The 2 mm backing is a modeling minimum, not a qualified structural limit.

### Current rail slot layout

MakerStack extracts ordinary openings from `maker_rail_2d` in `rails.scad`.
It does not recreate slots using the wider 15 mm support width.
Full-length X strips continue through corners; shorter Y strips meet them
with canonical 3 mm end bridges, without independent cap mounting holes.
The former 11 mm solid end pads are removed. Both terminal slots and their
underlying nut pockets extend 8 mm farther at each end; the 2 mm channel
walls, corner guides, key openings, and seating planes are unchanged.

The current rail API uses `edge_support_width=RACK_SUPPORT_WIDTH`, or
**3 mm**, at each end when `mounting_holes=false`. Do not substitute the
11 mm rail width for this end allowance. At the default Stack footprint,
the canonical X strip has seven approximately 32.977 mm long slots;
the shorter Y strip now has three approximately 33.117 mm long slots.
Regenerate matching printed supports and optional metal tops together;
the previous two-slot Y layout is not interchangeable with this outline.

Slot lengths redistribute with rail length and the 3 mm intervening ribs;
there is no fixed 1U slot repeat. The minimum-length expression
`5.75 * HP` evaluates to **29.21 mm**, despite an older 29.06 mm comment.
Four extra corner openings clear the fixed column axes. Regenerate caps
and supports together after updates; recheck panel-hole versus rib alignment.

### Pitch is not equipment clearance

`layer_pitch_u * U` is the Z distance between corresponding seating planes.
Panel span along Y and tier pitch along Z are independent dimensions.
The standalone seating height for zero-based tier `i` is
`foot_seat_height + frame_depth + i * layer_pitch_u * U`.
At the defaults, the two planes are Z=25 and Z=69.45.

Where equipment footprints overlap, available clearance is `P - a - b`:
`P` is pitch, `a` is intrusion above the lower plane, and `b` is intrusion
below the upper plane. Include panels, supports, controls, screw ends,
connectors, cables, and assembly margin. A 15 mm-deep upper rail leaves
29.45 mm below it at 1U pitch, before any lower upward intrusion.
That local value is not a uniform equipment envelope across the open bay.

Column shoulder height is `layer_pitch - frame_depth`, not the pitch itself.
Equipment with 60 mm under-panel depth does not automatically fit a 1U bay.
Bond thickness is not modeled and can alter assembled seating heights.

## Parameter reference

These are entrypoint defaults, not proven hardware or material tolerances.
Unlabeled numeric lengths are in mm. Hidden values are derived from the
controls and shared constants rather than separate configuration choices.

### Views and footprint

| Parameter | Default | Purpose |
| --- | --- | --- |
| `part` | `"assembly"` | Output selector; see table below |
| `panels` | `"top"` | `none`, `top`, or `all` sample panels |
| `explode_gap` | 12 | Separation used by `exploded` |
| `show_hardware` | `true` | Illustrative joint screws and nuts |
| `show_driver` | `true` | Driver envelope in `joint` only |
| `base_support` | `false` | Footed variant for `support` output |
| `frame_width_hp` | 48 | X rail-center spacing in HP |
| `panel_height_u` | 3 | Outer panel Y span in U |
| `layers` | 2 | Tier count including base; floored, minimum 1 |
| `layer_pitch_u` | 1 | Uniform seating-plane pitch in U |
| `preview_panel_hp` | 16 | Sample panel width, not frame width |
| `rail_metal_thickness` | 0 | Optional top sheet: 0, 1, 1.5, or 2 mm |

Customizer ranges include 24–96HP width, 2–6U panel span, 1–5 tiers,
and 1–3U pitch in 0.5U steps. These are UI ranges, not fit guarantees.

### Channel and structural joint

| Parameter | Default | Purpose |
| --- | --- | --- |
| `nut_channel_width` | 11 | Cavity width away from guides |
| `nut_channel_depth` | 7 | Depth below the printed rail backing |
| `nut_channel_radius` | 5 | Rounded bottom-corner radius |
| `nut_channel_wall` | 2 | Material on each side of cavity |
| `base_open_channels` | `true` | Open lowest spans between saddles |
| `frame_depth` | 15 | Seating plane to ring underside |
| `column_width` / `column_depth` | 14 / 14 | Integral post section |
| `access_diameter` | 6.2 | Screw-head and driver shaft bore |
| `screw_clearance` | 3.4 | Through-hole below recessed seat |
| `screw_seat` | 3 | Seat above lower seating plane |
| `key_width` | 10 | Locating tab dimension along X |
| `key_length` | 1.5 | Tab insertion below shoulder |
| `fit_clearance` | 0.25 | Per-side key and nut-guide allowance |

The default cavity has a 1 mm flat bottom between its corner arcs.
Closed pockets leave 5 mm below their deepest floor. Radius is limited
internally to cavity depth and half-width; that does not establish fit.
Key depth is `T_SLOT_HEIGHT - 2 * fit_clearance`, or 6.4 mm.
Keep useful floor, wall, and screw-seat material when customizing.

### Hardware envelopes and base feet

| Parameter | Default | Purpose |
| --- | --- | --- |
| `screw_diameter` | 3 | Illustrative M3 screw shaft |
| `screw_head_diameter` / `screw_head_height` | 5.5 / 3 | Head envelope |
| `screw_length` | 12 | Under-head length |
| `nut_length` / `nut_width` / `nut_thickness` | 5 / 8 / 2 | Nut envelope |
| `nut_guide_length` | 8 | Local anti-rotation guide length |
| `driver_diameter` / `driver_reach` | 4 / 60 | Display-only tool envelope |
| `foot_style` | `"screw"` | `screw` or unperforated `bond` pad |
| `foot_width` / `foot_thickness` | 32 / 4 | Pad X span and thickness |
| `foot_seat_height` | 10 | Surface to support-ring underside |
| `foot_hole_diameter` / `foot_hole_spacing` | 4.5 / 22 | Flange holes |
| `foot_access_diameter` | 6.5 | Inner screw-head access through floor |

The nut envelope is not a specified commercial part. External nut fit and
thread size are separate requirements. Do not treat M3, M5, and M6 hardware
as interchangeable, even where older rail comments suggest compatibility.
Changing a displayed screw envelope does not resize the independent bore.

## Part outputs and fabrication

| `part` | Output and intended use |
| --- | --- |
| `assembly` | Complete stack, optional sample panels and hardware |
| `exploded` | Separated assembly for understanding the part relationships |
| `frame` | Upper printed rail/support with optional metal reinforcement |
| `base` | Footed printed rail/support with optional metal reinforcement |
| `support` | One print including rails; `base_support` selects feet/columns |
| `top` | Optional metal outline, matching slots, for SVG/DXF export |
| `joint` | Actual two-tier joint cutaway with optional hardware and driver |
| `section` | 40 mm ordinary rail/channel inspection cutaway |
| `column` | Manual selector: standalone fit coupon, not a detachable post |
| `foot` | Manual selector: foot coupon, not a bolt-on production foot |
| `parts` | Manual selector: sample frame and coupons, not a complete kit |

Print one base support and `layers - 1` upper supports. Each includes its
slotted MakerRails; **no separate cap or bonding is required by default**.
Use `support` for a 3D print export. With metal disabled, `frame` and `base`
also contain only their respective complete printed part. With metal enabled,
they show both materials; use `support` to isolate the print.

`top` always provides the matching 2D laser outline, even at zero metal.
It does not encode stock thickness or select a material. Only fabricate it
when reinforcement is selected: use laser-cut metal sheet (for example,
aluminum) at exactly `rail_metal_thickness`, **not the effective `cap`**.
Qualify the chosen alloy, stock, cutting process, surface preparation, and
adhesive. A 2 mm sheet requires the matching 4 mm-total rail configuration;
do not glue it onto the default 3 mm print and expect unchanged datums.
`exploded` lifts only the optional sheet, never the integral printed rail.
`rails_laser.scad` generates standalone rail strips, not the Stack cap.

Physical part selectors place the lowest surface at Z=0. Module calls use
the cap seating plane as Z=0, with the support and columns below it.
Bed placement is not a tested print orientation: assess bridging, supports,
layer adhesion, and dimensional error before fabrication.
Cutaway ends are inspection surfaces, not nut-loading ports in full frames.

For custom hosts, reuse `makerstack_support`, `makerstack_frame`, and
`makerstack_top_2d`. Keep their footprint and joint arguments consistent.
Case adapters should reuse these interfaces rather than scale panel slots.

### Reusable API contract

Existing positional arguments keep their order; only trailing `metal=0`
is added to the two support/frame modules:

- `makerstack_support(base=false, frame=frame_width, spacing=rail_spacing,
  pitch=layer_pitch, depth=frame_depth, cap=rail_thickness, channel=channel,
  nut=nut, post=post, metal=0)`
- `makerstack_frame(base=false, cap_lift=0, frame=frame_width,
  spacing=rail_spacing, pitch=layer_pitch, depth=frame_depth,
  cap=rail_thickness, channel=channel, nut=nut, post=post, metal=0)`
- `makerstack_rail_total_t(full_t=3, metal_t=0, printed_min_t=2)`

The vector names above abbreviate the unchanged defaults:
`channel=[nut_channel_width,nut_channel_depth,nut_channel_radius,
nut_channel_wall]`, `nut=[nut_width,fit_clearance,nut_guide_length]`, and
`post=[column_width,column_depth,screw_seat,access_diameter,screw_clearance,
key_width,key_depth,key_length]`. At source defaults they evaluate to
`[11,7,5,2]`, `[8,0.25,8]`, and `[14,14,3,6.2,3.4,10,6.4,1.5]`.

Custom hosts compute `cap` with the helper and pass `metal` explicitly to
both modules. The modules honor the supplied total, rather than silently
recomputing it; callers must retain the desired printed backing. Negative
metal is treated as zero. Keep host hardware and channel datums on that
same total. `cap_lift` is display-only and has no effect without metal.
`makerstack_top_2d` and its arguments are unchanged. With `use`, do not
assume the importing host's Customizer settings replace library defaults.

## Four corner columns and the top-down joint

Posts sit at X=±frame_width/2 and Y=±rail_spacing/2, the exact rail-centerline
intersections. They do not track the first or last ordinary slot centers.
The 14 by 14 mm columns fit beneath the 15 mm support strips and remain
outside the central opening. Each upper ring and its columns are one print.

The shoulder bears on the lower cap; a 10 by 6.4 by 1.5 mm key enters a
10.5 by 6.9 mm corner opening. The key locates the tier; it is not a snap
lock. The cap retains a 2.25 mm outer end web at these default openings.
A recessed screw seats 3 mm above the lower plane and engages a guided
nut beneath the lower cap. There is no hidden upper column fastener or
full-height tie rod.

The default screw tip reaches 9 mm below the lower seating plane, leaving
1 mm above the deepest pocket floor at the axis. Check actual engagement,
head fit, and screw length; resistance alone does not prove nut pickup.
The default guide has an 8.5 mm transverse gap and an 8 mm length.
Turn the nut beside it in the wider pocket, then slide into the guide.

A slender driver reaches through the upper slot and 6.2 mm axial bore.
At 1U pitch it needs at least 38.45 mm reach below the upper seating plane,
plus clearance above for its handle. Larger pitch requires longer reach;
bulky interchangeable-bit holders will not fit this modeled path.
Reserve all four post slots and neighboring loading areas from panels,
panel screws, electronics, and cables.

### Bond only optional reinforcement

Printed rails are integral with their supports and need no cap-to-support
adhesive. If metal is selected, **bond every sheet to its printed backing**,
including single and topmost tiers; no independent sheet screws are modeled.
The next tier's clamp is not a substitute for sheet retention. Keep adhesive
out of slots, pockets, and shafts. Qualify the bond and account for cured
thickness, which is not included in the modeled stack.

### Assembly and service sequence

1. Test the hardware and full driver path in the integral printed rails.
   If using metal reinforcement, bond it and let it cure before loading.
2. Secure the footed base to its substrate. Keep inside and outside flange
   screw paths accessible, or qualify the selected base-pad adhesive.
3. Insert each lower-tier nut lengthwise through a slot beside its guide.
   Rotate it across the slot in the wider pocket, then slide into the guide.
   A point 9.5 mm inward along X from the post axis is the default loading
   reference; test the real hardware's swept envelope rather than force it.
4. Lower the next complete tier. Seat its keys and shoulders on the lower
   finished rail surface, not on panel material or wiring.
5. Drop screws down the shafts and tighten from above with the slender
   driver. Confirm engagement and avoid crushing the printed screw seats.
6. Only after tightening, load nuts for the next tier. Earlier loading
   blocks the same shafts needed to secure the current tier.
7. Add equipment without covering the reserved areas and repeat upward.
   Leave the top tier's guides empty unless adding another tier.

Disassemble top-down. Remove loose nuts from each newly exposed rail before
using its shafts to reach the next screws. A loaded middle tier cannot be
removed independently. Support equipment and disconnect cables as needed.

## Open channels, feet, and case adapters

The lowest tier defaults to open-bottom channel spans, retaining local
14 mm foot/nut saddles. Upper tiers retain their rounded-pocket floors.
Set `base_open_channels=false` for closed lowest pockets. Top-slot ribs
remain in either version; an attached screw cannot slide through those ribs.

Open spans do not retain loose nuts underneath. Use a temporary screw while
loading and turning a nut, then slide it onto its saddle before releasing it.
Neither the 11 mm cavity width nor a successful render proves this path fits.

Standalone pads measure 32 by 15 mm, with 14 mm stems. They project 8.5 mm
beyond each X side of the ring. Flange holes are 22 mm apart along X.
Inner screw heads pass through rail slots and 6.5 mm floor access holes;
outer screws need unobstructed access beside the frame.
The bonded variant has unperforated pads; upper tiers remain removable.

Hard Case Stack instead uses a low case-conforming base without these
outboard feet and merges peripheral bridges into upper supports. Its case
records, first-interval options, and export datums belong to that adapter,
not this standalone entrypoint. In Riptide, see `docs/hard_case_stack.md`.
Putting ordinary feet inside a case does not make them contour-conforming.
Wall clearance is not a fastening method or proof of lateral support.

## Qualification checklist

- Test nut insertion, turning, sliding, anti-rotation, and dropped-nut pickup.
- Check panel-hole alignment, occupied slots, driver reach, and service order.
- Measure real pitch, equipment clearance, cables, ventilation, and lid fit.
- Test compression, separation, racking, torsion, and repeated assembly.
  No diagonal bracing is modeled; do not assume removable panels supply it.
- Check printed rail bending, screw-seat crushing, print orientation, creep,
  temperature exposure, and wear with representative equipment loads.
  When metal is used, also test reinforcement bending and bond peel.
- Qualify base attachment separately. Ordinary epoxy is not a dependable
  default for polypropylene; use a substrate-compatible bonding process.
  Through-fastened weatherproof shells also need a sealing strategy.

Smaller inset tiers need dedicated carriers and matching joint/tool paths.
Fixed-height integral columns do not telescope. Screenshots and dimensional
checks establish neither physical fit nor safe working loads; validate the
chosen materials, hardware, adhesive, and complete installation before use.