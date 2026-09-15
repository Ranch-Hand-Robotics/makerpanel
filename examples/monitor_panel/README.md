---
title: Fixed-Angle Monitor Mount
category: Visual Feedback
description: >-
  Two-piece fixed-angle monitor support with a tabbed VESA plate,
  side-screwed wedge sockets, an open underside, and IsoGrid skins.
---

# Fixed-angle monitor mount

Two prints separate rail installation from monitor attachment:

- **MakerPanel:** base, enclosed wedge walls, and four upward-open sockets.
- **VESA panel:** inclined plate and four downward tabs with blind pilots
  for self-tapping screws driven through the wedge from outside.

There are no sliding tracks, pivots, separate arms, stow magnets, or moving
angle adjustments. Solid side, front, and rear walls support the plate, forming
a hollow wedge. The MakerPanel floor inside the wedge is removed completely,
including its grid ribs, except for four localized socket blocks beside the
side walls. The central cavity stays open from below, with no internal
gussets or crossbars. The exposed base and inclined face
retain IsoGrid; this is an enclosed-sided support, not a sealed enclosure.

**Prototype, not load-rated.** Geometry checks do not establish strength,
creep resistance, stability, or safe carrying loads for the offset display.

## Angle and placement

The current default is **15° from horizontal**, with a **30° maximum**,
giving a shallow incline like the Stream Deck top. `monitor_angle` changes
the geometry to fabricate; it is not an adjustment mechanism. The Customizer
offers 15–30°.
The wedge walls stay inside the MakerPanel footprint, independently of the
VESA plate width. Only the thin inclined plate may overhang. The rear wall
ends at the supporting face or at the panel's rear inset on shorter panels.
The base and wall roots remain at Z = 0. The overhanging plate is entirely
at or above the panel's **top** surface, not its underside.

### Vertical lip clearance

`monitor_offset_z = 0` places the **lowest underside of the support lip**
at the MakerPanel top (Z = `panel_depth`). Positive values add that many
millimeters of vertical clearance: 10 means the lip starts 10 mm above the
panel top. The whole inclined plate and monitor rise together, preserving
the full 4 mm plate thickness; the lip is not shaved thinner or clipped.
The monitor back sits another `face_thickness * cos(monitor_angle)` above
that datum. The offset is measured vertically, not along the tilted axis.

The contained wedge walls grow taller while their roots remain on the panel.
A front wall closes the gap under the raised lip **inside the wedge only**;
the overhang remains a thin plate with no wall below it. The cavity stays
open underneath. Adjacent hardware must fit below the lip clearance plane;
allow real assembly tolerance rather than relying on exact surface contact.

Coordinates remain **−Y front, +Y rear, +Z up**. The display faces −Y.
The **screen-facing bottom edge** is exactly in the panel's front plane.
The monitor's back bottom edge sits above the full-thickness support lip.
Accounting for the monitor's thickness keeps its display face within the
front edge plane.

At the current 2U, 15° and zero Z offset, with 15 mm monitor thickness:

- Panel front: Y = −44.45 mm; panel top and lowest lip underside: Z = 3 mm.
- Monitor back bottom: Y = −40.568 mm, Z = 6.864 mm.
- Screen-facing bottom: Y = −44.45 mm, Z = 21.353 mm.
- Monitor X extent: −280..420 mm, preserving the 70 mm lateral offset.

The inclined support contacts the monitor back directly, with no face bosses.
Its underside clears the panel top. The wedge's sloped rim seats against
the plate underside without overlapping it. Tabs locate the plate and
side screws retain it; this is a detachable joint, not a fused wall/roof.

## Inputs and mounting pattern

| Input | Default |
| --- | --- |
| `horizontalPitch` / `verticalUnits` | 35 HP / 2U |
| `panel_depth` | 3 mm |
| `monitor_width` / `monitor_height` / `monitor_depth` | 700 / 190 / 15 mm |
| `monitor_offset_x` | 70 mm |
| `monitor_offset_z` | 0 mm from panel top to lowest support-lip underside |
| `monitor_row_offset` | 90 mm from actual bottom, along monitor back |
| `monitor_angle` | 15° from horizontal; maximum 30° |
| `face_thickness` / `wall_thickness` | 4 / 4 mm |
| `vesa_plate_width` | 0: automatic panel-root and screw-pad span |
| `driver_diameter` | 13 mm rearward head/driver clearance |
| `base_isogrid` / `face_isogrid` | true / true |
| `grid_triangle` / `grid_rib` / `grid_hole` | 25 / 3 / 5 mm |
| `grid_border` / `grid_margin` | 10 / 4 mm |
| `mount_washer_diameter` / `vesa_bearing_diameter` | 7 / 9 mm |
| `tab_thickness` / `tab_length` / `tab_depth` | 11 / 12 / 8 mm |
| `tab_clearance` | 0.3 mm per side and beneath the tab |
| `socket_wall` | 2 mm inner/end cheeks |
| `screw_hole_diameter` | 2.5 mm receiving pilot |
| `screw_hole_taper_depth` / `screw_hole_thread_depth` | 1.8 / 7 mm |
| `screw_head_diameter` | 5.25 mm |
| `side_screw_thread_clearance` | 0.25 mm added to wall hole diameter |
| `side_screw_head_clearance` | 0.2 mm added to recess diameter |
| `side_screw_head_recess_extra` | 0.4 mm added to recess depth |
| `assembly_lift` | 0 mm; preview-only vertical separation |

The original **two-hole row**, not a four-hole square, is retained:
75 mm center spacing, 4.5 mm through-bores, X = 32.5 and 107.5 mm.
Both bores pass **through the inclined supporting face**, normal to the
monitor back. The screw row does not move when monitor height changes.

The right screw intentionally lies beyond the base's +88.9 mm side edge.
The face expands asymmetrically to X = −74.9..118 mm to retain that screw's
bearing material. Its width is 192.9 mm, height 100.5 mm. The wedge itself
is only **149.8 mm wide**, X = −74.9..74.9 mm, leaving 14 mm to each panel
side. Side walls occupy X = −74.9..−70.9 and 70.9..74.9 mm; the rear wall
spans only that narrower wedge. No wall extends past the panel edge.

The right overhang is the **4 mm inclined plate alone**, extending 43.1 mm
beyond the wedge wall (29.1 mm past the panel edge). Its continuous screw-row
band and solid wall-root strips connect the screw pads to the wedge. Raising
`vesa_plate_width` enlarges the plate, not the walls or underside opening.
This thin cantilever needs physical validation, not a rated-capacity claim.

## Enclosed wedge, open underside, and IsoGrid

- Two solid 4 mm side skins and solid 4 mm front/rear walls replace the open
  gussets. Their sloped tops seat against the inclined face without entering
  it or the monitor envelope. There is no wedge infill or internal bracing.
- The base floor opening spans X = −70.9..70.9 mm between the front and
  rear wall inner faces. It removes the entire panel thickness there,
  including the former IsoGrid ribs, without reaching either panel side.
  Four local socket blocks project inward beside the side walls, each with
  a blind-bottom slot. They do not bridge or refill the central cavity.
- Only the perimeter wall roots, sockets, and protected attachment strips
  remain under the roof. Disabling `base_isogrid` **does not fill the floor**.
- The exposed base and inclined face retain IsoGrid openings; disable either
  toggle for solid skins. Perimeter walls are always solid except for
  localized screw-access reliefs.
- A 10 mm skin perimeter, wall-root keepouts with 4 mm outside margins,
  the front attachment strip, and a transverse screw-row band remain.
- Mounting and VESA bearing pads retain surrounding material. Grid node
  holes never replace the functional screw bores.
- VESA bores and 13 mm head/driver corridors are cut in each part. Install
  the monitor on the detached plate rather than relying on below-deck access.
  The retained corridors also provide screw-head clearance when seated.

`isogrid_rect` returns **positive ribs**. The cutters subtract their
complement, excluding the root and bearing keepouts. All four native panel
bores are cut again after union to ensure no added material fills them.

Large input changes still require a fit review: keep the wall roots joined
to the panel, a positive floor opening, the support face inside the monitor
outline, and the screw row within the monitor height. Customizer ranges
are not a promise that every combination is structurally or geometrically
suitable. In particular, narrow panels and high screw rows need redesign.

## Fabrication and assembly

### Outside screw geometry

The four side joints use the supplied **McMaster-Carr 95893A189** screw-for-
plastic dimensions, adapted from `deck_nomad/designs/cyberdeck.scad`:

- `bottom_skin_screw_holes_3d`: the wedge wall has a **5.45 mm to 2.75 mm
  tapered entry, 2.2 mm deep**, followed by clearance through the rest of
  the 4 mm wall. Both entries face outward.
- `cyberdeck_screw_holes_perimeter`: the receiving tab has a **straight
  2.5 mm blind pilot, 8.8 mm deep** (1.8 + 7), not a head recess or an
  enlarged clearance bore. The 11 mm tab leaves 2.2 mm of closed-end material.
- As in those active cyberdeck cutters, the cone is specified by diameters
  and depth. The cyberdeck's `screw_hole_taper_angle` is unused there; this
  is **not an exact 90° countersink**. Its path inset and spacing controls
  do not apply to this four-tab pattern and are not imported.

The tabs and sockets grow inward only. No nuts or threaded inserts are
needed. The original VESA and rail fastening holes are unchanged. The model
uses the supplied dimensions, not independently verified supplier data:
check actual screw length, thread diameter, head fit, and printed pilot fit.
The 0.25 mm clearance increment is inherited from the deck; increase it if
the screw threads do not pass freely through the wedge wall.

### Assembly order

1. Export **both** `part = "makerpanel"` and `part = "vesa_panel"` with
  identical dimension settings. Exports retain assembly coordinates; orient
  each in the slicer. `assembly` previews both, plus the optional monitor.
  Set `show_monitor = false` and `assembly_lift = 30` for an exploded view;
  the lift never changes either individual export or the actual Z offset.
2. Inspect the sliced slots, tab roots, blind pilots, cantilever, and grid
  strokes. Test the fit before loading. Choose material, print orientation,
  supports, and wall count for the load; this is not a support-free claim.
3. Bolt the bare MakerPanel/wedge to the rails from above. Leave access to
  **both sides** of the wedge for the four horizontal locking screws.
4. Attach the detached plate to the supported monitor using its two approved
  screws from behind. Select length for the **4 mm face plus any washer plus
  manufacturer-approved thread engagement**. Do not guess engagement depth.
5. Lower the monitor and plate **vertically** so all four tabs enter the slots.
  Seat the underside against the sloped rim. Tabs have 0.3 mm bottom and
  per-side clearance; the rim, not the slot floors, sets the height.
6. Insert four self-tapping screws horizontally through the outside wedge
  walls into the tab pilots—two per side. Start all four before gently
  tightening by hand. The
  screw axes are parallel to X, not perpendicular to the inclined roof.
  The tab entry is 4.3 mm inward from the outside wall; the blind pilot ends
  at 13.1 mm. Check the seated screw's tip position, allowing bottoming
  clearance and accounting for its head seating and unthreaded tip. A 7 mm
  pilot-engagement target is not a guarantee of 7 mm full-thread contact.
  Do not reuse the previous M3×12 recommendation for these screws.
7. Verify cable/vent clearance, side-driver access beneath the overhang,
  thread grip, rail support, and twisting resistance before loading.
  Confirm that the monitor manufacturer permits this two-hole row.

To remove the monitor, support it, remove the four side screws, and lift
vertically. The rail screws and VESA screws can stay installed.

Required hardware: four rail-compatible panel fasteners, two manufacturer-
approved monitor screws, and **four self-tapping side screws for plastic**.
Use suitable washers for rail/VESA hardware as needed, not ordinary washers
in the side countersinks. No nuts, inserts, or magnets are needed for the tabs.
Repeated removal can wear printed threads; test the joint before loading.

The current 2U geometry and 15–30° angles are covered by interface checks.
A 1U base, changed pilot depths, narrow widths, or different screw rows need a
new fit review: do not assume every Customizer combination leaves adequate
socket depth, tab edge material, or screw clearance. No load rating is implied.

## Exports and validation

Existing STL, GLB, and brace SVG files in this directory belong to the old
articulated design. **They are stale and must not be used for this revision.**
They are left untouched; regenerate both new parts from `monitor.scad`.
The gallery no longer offers obsolete articulation part selectors.
Its auxiliary asset inventory may still include the historical brace SVG;
the fixed mount does not import or use it.
Do not combine old exported base/carrier parts with this design.

`fixed-mount.test.cjs` checks source-derived dimensions, sequential variable
dependencies, front-edge placement, normal screw paths, wall/roof seating,
the unconditional floor opening, panel-contained walls, plate-only overhangs,
vertical lip clearance, offset-independent roots, tab insertion, blind pilots,
side-driver envelopes, and catalog selectors.
Run it with Node's test runner alongside `examples/part-selectors.test.cjs`.
These are analytic/source-contract checks, not mesh certification or FEA.
Use the URDF editor's embedded OpenSCAD renderer for visual verification;
no local OpenSCAD installation or intermediate SCAD probe is needed.

Keep the repository root in the renderer's library search paths so
`makerpanel/panel.scad` and `examples/vent_panel/IsoGridScad/isogrid.scad`
resolve. Open the repository as a VS Code workspace folder.

## MakerPanel compatibility

The library yields **177.8 × 88.9 mm** at 35 HP/2U, with four **3.5 mm**
panel bores centered at [±83.4, ±38.95] mm. These are M3-clearance holes,
not M5/M6 clearance; choose a compatible screw/nut combination for the rail.

The [specification](../../docs/specification.md) distinguishes a 128.5 mm
3U panel from nominal 133.35 mm unit spacing, whereas the current API uses
`u_to_mm(u) = u * 44.45`. This design preserves the existing API behavior.
The inclined assembly and display overhang are custom extended geometry,
not a claim of whole-assembly compliance with the standard 60 mm envelope.