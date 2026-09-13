---
title: Folding Monitor Mount
category: Visual Feedback
description: >-
  Articulating Monitor mount that slides from flat stow to upright.
---

# Low slotted-block monitor mount: flat stow to 90 degrees

## Current revision: bottom-referenced VESA row

`monitor_row_offset = 90` now measures from the **actual monitor bottom**
to the screw centers, not from the monitor center. Increasing monitor height
does not move the row. Old center-referenced presets must be converted by
adding half the monitor height (the old +60 becomes 155, not 90).

At the current 190 mm monitor height:

| Feature | Current dimensions (mm) |
| --- | --- |
| Monitor bottom / VESA row, carrier-local Y | 7.8 / 97.8 |
| Main carrier plate XYZ | X -75.2..116.5; Y 7.8..107.8; Z 8.3..11.3 |
| Main plate size | 191.7 x 100 x 3, previously 192.5 x 165 x 3 |
| Arm-pivot cheek gap / washer per side | 4.2 / none |
| Slider reinforcing ribs, local Y | 0..91.35, ending at the D-pivot band |
| Outer stow pad centers, base XY | [±70.2, -16.55] |
| Outer magnet centers, carrier XY | [±70.2, 64.35] |
| Inner stow pad centers, base XY | [±35, -1.55] |
| Inner magnet centers, carrier XY | [±35, 79.35] |
| Compact inner seats, local Y / Z | 74.7..84 / 4.8..10.3 |

### Washer-free arm-pivot fit

All four arm joints now have **4.2 mm** between their printed cheeks for
the 4 mm metal arms, with **no arm-pivot washers**. `washer_thickness = 0`
omits all eight arm washers and leaves the `pivot_washer` selector empty.
`pivot_clearance = 0.2` is total free space, or **0.1 mm per side**.
Adjust it to suit measured stock and print tolerances; zero is available
but may bind. Optional washers can still be modeled by setting their actual
per-side thickness; the gap includes them plus `pivot_clearance`.

This changes lateral cheek spacing, not the 5.4 mm pivot bores or the
bottom slider's running gaps and M4 hardware. Physical fit still depends
on measured arm thickness and print tolerances. The automatic plate bounds
explicitly include the stow footprints so narrower joints do not clip them.

The two 8 mm-wide slider ribs now stop at the far side of the brace
connection band rather than continuing to the plate top. Relative to the
already-shortened plate, this removes 2.18 cm³ of rib material below the
skin. The plate perimeter, transverse bands, bearing pads, pivot cheeks,
bores, and magnet pocket roofs remain. This is a conservative material
reduction, not evidence that every remaining region is structurally optimal.

The inner base posts and their carrier magnet seats now follow the folded
middle-pivot station. The seats are compact **10 x 9.3 mm** bosses entirely
under the plate, with 2 mm overlap into its skin. There are no extended bars
reaching back to the former rear docking station.

The outer posts sit **ahead of the middle-pivot cheeks**, not merely outside
the narrower metal arms. Their rear faces have a nominal **2 mm folded gap**
to the cheeks (`stow_pivot_gap`). The plate-end and screen constraints can
move them farther forward. All pockets, cushions, and skin keepouts follow
their respective posts. Re-export both printed parts as a matched pair;
existing STL/GLB exports are stale.
Monitor position, linkage axes, arm length, and folded height are unchanged.

Source-derived checks cover the bottom datum, rib endpoints, dock root
overlap, all four folded magnet pairs, and linkage closure at 1,001 poses.
An additional check reproduces the former outer-post/D-riser collision,
then passes 16,016 envelope comparisons at 1,001 poses for both stow pairs
against the plate, monitor, seats, pivot cheeks/risers, and pivot hardware.
This is a sampled local interference check at current defaults, not a full
assembly collision proof, mesh certification, or structural analysis.
Physical testing with the monitor supported is still required; the prototype
remains **not load-rated**.

## Previous revision reference (superseded dimensions)

The detailed notes below describe the former **center +60 mm / bottom
155 mm** row and full-length ribs. Their plate, stow-post, magnet, and
reinforcement dimensions are historical, not current fabrication values.
Use the current revision above and `monitor.scad` for those dimensions.

`monitor.scad` folds the unchanged monitor **flat, shifted toward panel rear**,
then lifts it to **exactly 90 degrees at the rear**. One transverse **M4x45
screw** slides directly through **one solid 20 mm-wide housing with a
long closed through-slot** and both carrier lugs. There are no sleeves,
T-rails, moving shoes, extra bridge or VESA contact bosses. Two rear metal
arms connect to D axes **10.95 mm below the plate midpoint**. The housing
ends are flush with the MakerPanel; its rear reserve is solid, not extra travel.

**Fit prototype, not load-rated. Support during motion AND while deployed.**
This compact revision has **no lock**, counterbalance or transport latch.
Rear pads stop over-opening; they do not prevent folding. The former
cross-lock's sideways insertion corridor would cross a slot wall at this
height, so it is omitted rather than modeled as inaccessible hardware.
Four magnetic pairs meet only when folded: four base pockets and four
matching pockets at the **TOP/far end of the broad VESA underside**.
The extra bottom-edge tabs and their upright docking pockets are removed.
All eight magnets are in printed parts: nothing is bonded to, drilled into,
or cut out of the monitor. Magnetic attraction is unverified, not a lock.

## Preserved inputs and coordinates

| Input | Default |
| --- | --- |
| `verticalUnits` / `horizontalPitch` | 4U / 35 HP |
| `monitor_width` / `monitor_height` / `monitor_depth` | 700 / 190 / 15 mm |
| `monitor_row_offset` / `monitor_offset_x` | +60 / +70 mm |
| `metal_thickness` / `panel_depth` | 4 / 3 mm |
| `vesa_plate_width` | 0: automatic minimum width |
| `part` / `deployment` | `assembly` / 0 |
| `show_monitor` / `show_hardware` | true / true |
| `base_isogrid` / `carrier_isogrid` | true / true; independently disable for solid comparison |
| `grid_triangle` / `grid_rib` | 15 / 3 mm |
| `grid_border` / `grid_margin` | 10 / 4 mm |
| `mount_washer_diameter` / `vesa_bearing_diameter` | 7 / 9 mm bearing envelopes, not fastener seats |

+Y is rear, +Z is up, and all pivots are parallel to X. Carrier-local +Y
points toward the screen top; +Z is its display face. Positive X rotation
gives normal `[0,-sin(theta),cos(theta)]`: `[0,0,1]` at 0 degrees,
`[0,-0.707107,0.707107]` at 45 and **`[0,-1,0]` at 90**. No mirroring.

The actual screen bottom is local Y = **7.8**, top **197.8**, center
**102.8** and screw row **162.8**. Thus the row is still **155 mm from
the actual bottom** (190/2 + 60). Screw X positions are 32.5 and 107.5,
75 mm apart. Requested extra plate width grows equally on both sides.

## Exact default geometry

All lengths below are mm; repeating values are rounded to six decimals.

| Geometry | Default |
| --- | --- |
| Panel XYZ | X -88.9..88.9; Y -88.9..88.9; Z 0..3 |
| Screen folded XYZ | X -280..420; Y -73.1..116.9; Z 22.5..37.5 |
| Screen deployed XYZ | X -280..420; Y 39.862753..54.862753; Z 19..209 |
| Sliding axis S folded [Y,Z] | [-80.9, 11.2] |
| Sliding axis S deployed [Y,Z] | [66.162753, 11.2] |
| Fixed rear axes B [Y,Z] | [78.8, 11.2] |
| D axes folded / deployed [Y,Z] | [-1.55,11.2] / [66.162753,90.55] |
| Arm center planes / hole spacing | X = -63 and +63 / 80.35 |
| Physical plate local XYZ | X -76..116.5; Y 7.8..172.8; Z 8.3..11.3 |
| Slider stroke | **147.062753** |
| Slot-housing X bounds / width | -10..10 / 20 |
| Slot-block Y bounds / length | -88.9..88.9 / 177.8 |
| Slot-block Z bounds | 2.5..18.4 |
| Through-slot cut X bounds | -11..11 |
| Capsule centerline Y / Z | -80.9..66.162753 / 11.2 |
| Capsule outer Y bounds | -83.15..68.412753 |
| Slot bore Z bounds / radius | 8.95..13.45 / 2.25 |
| Roof / front end / rear end ligaments | **4.95 / 5.75 / 20.487247** |
| Floor ligament above panel / full block | **5.95 / 6.45** |
| Bottom lug X intervals / bore diameter | -18.5..-10.5 and 10.5..18.5 / 4.5 |
| Rear pad contact faces | X -60..-48 and 48..60; Y 39.862753..54.862753; Z 19 |
| Stow pad contact faces | X -75.2..-65.2 and 65.2..75.2; Y 59.5..69.5; Z 19.5, excluding circular openings |
| Inboard stow pedestal XYZ | X -40..-30 and 30..40; Y 55.862753..65.162753; Z 2.5..15.5 |
| Inboard stow cushion faces | Same pedestal XY; Z 15.5..16, excluding circular openings |
| Folded dock boss local XYZ | X -40..-30 and 30..40; Y 136.762753..146.062753; Z 4.8..10.3 |
| Folded dock pocket local centers / Z | XY [±35, 141.412753]; Z 4.8..6.9 |

The folded screen center is Y = **21.9**, a 21.9 mm rearward shift from
the previously centered layout. It leaves **15.8 mm** of panel uncovered
at the front and has **28 mm** rear screen overhang. The plate ends at
world Y = 91.9, a **3 mm** rear plate overhang. The unchanged width and X
offset imply lateral screen overhangs of 191.1 mm left and 331.1 mm right.
At 90 degrees the entire screen thickness lies in the rear third of the
panel; its back is 34.037247 mm forward of the rear edge.

### Flush housing and intentionally shifted screen

The housing spans exactly `panel_front..panel_rear`, with no front or rear
projection. Its full **177.8 mm** length joins the panel directly across
20 mm width and 0.5 mm depth, including both end regions; no extra platform.
The full 8 mm-radius lower lugs remain inside the front plane:
`slider_start = panel_front + slider_lug_radius = -80.9`.
The whole folded assembly spans Y = -88.9..116.9.

Keeping B fixed and using `brace_length = carrier_span + 1` requires
`carrier_span = (fixed_b.y - slider_start - 1)/2 = 79.35`.
This moves the physical D connection down the plate rather than trimming
its full bottom reinforcement. Centered folded coverage is deliberately
traded for a flush housing and retained lower lugs.

The slot runs only between the reachable axle centers. Its rounded rear
end is Y = 68.412753; the remaining **20.487247 mm** to the panel rear is
solid reserve, not an extension of travel. `housing_envelope_radius`
preserves the roof height and screen-bottom offset; `slot_radius` controls
only the cut, not housing bounds or motion.

### Folded stack and limiting dimensions

Folded height above the panel underside is **37.5 mm**, down **18.5 mm
(33.0%)** from 56 mm. Height above the panel top is 34.5 mm. Both pivot
axes dropped from 25 to 11.2 mm; the plate face dropped from local Z = 16
to 11.3 mm. The stack is:

- 3 mm panel + 8 mm moving-boss radius + 0.2 mm clearance = axis Z 11.2.
- 8.3 mm axis-to-plate underside: clears the 8 mm pivot bosses, slot roof
  and rear pads during the sweep.
- 3 mm carrier plate, then the unchanged 15 mm monitor.

Total: **3 + 8 + 0.2 + 8.3 + 3 + 15 = 37.5 mm**. This is flat as
practical with these simple round bosses and a flat carrier contact plane,
not a global optimization claim. Going materially lower needs redesigned
boss profiles, plate reliefs or smaller hardware—not a concealed collision.
The 3 mm carrier and full-length housing root still need physical testing.

## Isogrid skins and retained reinforcement

Both skins have triangular cutouts by default. The existing
[IsoGridScad library](../vent_panel/IsoGridScad/isogrid.scad) is reused via
`use <examples/vent_panel/IsoGridScad/isogrid.scad>`, as in
[Antenna](../Antenna/antenna.scad). No copied library, new submodule,
local OpenSCAD installation or probe SCAD is required. The monitor base
remains **35 HP/4U, 177.8 mm square**, not the vent example's 2U size.

### Library search setup

Use the MakerPanel repository root as a library search path, not the
`examples/monitor_panel` directory. Keep the portable library-root import;
do not replace it with a machine-specific absolute path. Open the repository
root as a VS Code workspace folder. The installed URDF editor extension
already includes **all workspace roots** alongside `OpenSCADLibraryPaths`
in `configuredLibraryPaths`, and passes these plus `workspaceRoot` to
`convertOpenSCADWithNodeWorker`. This is not a browser-only conversion path.
Other hosts must likewise include the repository root in their library paths.

### Subtractive skin construction

`isogrid_rect` produces a **positive solid rib network**, not cutout tools.
`skin_voids` takes an inset rectangle **minus that network minus structural
keepouts**, then extrudes those triangular voids. The tool is subtracted
outside each complete root-solid union. Base tools span Z **-0.01..3.01**;
carrier-local tools span Z **8.29..11.31**. Existing holes and bores remain
subtractive. Nothing fills a bore or adds a monitor-face boss; the monitor face
is still flat at local **Z = 11.3**. Non-skin roots stay intact apart from
the intentional blind magnet pockets in the stow and docking features.

The default triangle side is **15 mm** (perpendicular stroke pitch
**12.990381 mm**), with **3 mm** retained strokes at **0/±60 degrees**.
Patterns are centered on each skin's bounding rectangle. Node holes and
both chamfers are explicitly **zero**. Controls allow triangle sides
10..30 mm, ribs 3..5 mm, borders 10..20 mm and outside-root margins
4..8 mm; guards require positive triangular openings and inset area.
These ranges are geometry controls, not qualified structural limits.

The **10 mm perimeter** is solid apart from original functional mounting
holes and the new blind underside magnet pockets. `skin_roots` projects
the complete box and round XY envelopes from
the geometry tables; rear-support Y bounds come from the actual YZ polygon.
Every rectangular root mask extends **4 mm beyond all four footprint
edges**, including corners. Defaults below include this margin; masks are
clipped to the existing skin outline, never used to enlarge it.

| Protected zone | Default retained XY extent (mm) |
| --- | --- |
| Base full track foundation | X -14..14; full Y -88.9..88.9 |
| All four base brace feet and round cheek roots | X -78..-48 and 48..78; Y 66.8..88.9 |
| Both base rear-support footprints | X -64..-44 and 44..64; Y 35.862753..58.862753 |
| Both base stow-support footprints | X -79.2..-61.2 and 61.2..79.2; Y 55.5..73.5 |
| Both carrier full-length slider ribs | X -22.5..-6.5 and 6.5..22.5; full skin Y 7.8..172.8 |
| All four carrier D-riser/cheek roots | Mirrored X 48..78 (clipped on left); Y 67.35..91.35 |
| Continuous transverse D connection band | Full carrier width; Y 67.35..91.35 |
| Continuous transverse VESA screw-row band | Full carrier width; Y 154.3..171.3 |
| Both carrier-local stow contact footprints | X -79.2..-61.2 and 61.2..79.2 (clipped on left); Y 136.4..154.4 |
| Both base inboard stow roots | X -44..-26 and 26..44; Y 51.862753..69.162753 |
| Both carrier folded docking roots | X -44..-26 and 26..44; Y 132.762753..150.062753 |

Stow contact centers are `x = ±stow_lane`,
`y = stow_y - slider_start`; actual default contact footprints are
X ±65.2..75.2 and local Y **140.4..150.4**, excluding the magnet mouths.
Protecting only the pedestals on
the base would not preserve contact on the perforated carrier. These masks
follow the forward relocation on 5U and lower-row variants. They protect
the entire 10 x 10 mm region, including each pocket's surrounding walls
and roof; the circular pocket is then subtracted, never filled by a mask.

Four base pads follow the API's actual hole centers **[±83.4, ±83.4]**:
`RACK_RAIL_HEIGHT/2 = 5.5 mm` inset, **3.5 mm** bore diameter. Retained
pad radius is `max(8, mount_washer_diameter/2 + grid_margin)` = **8 mm**.
Pads near the edge are clipped by the original perimeter. Each actual
VESA center (**[32.5,162.8]**, **[107.5,162.8]**) has radius
`max(8, vesa_bearing_diameter/2 + grid_margin)` = **8.5 mm**. Its bore
remains **4.5 mm** diameter, including when it crosses an underside rib.
The 64-sided pad masks are circumscribed so facet midpoints retain the
specified radius. Set bearing envelopes to encompass the purchased washer
and nut (include hex corners); they do not change hole sizes or add seats.

Both transverse bands meet the side borders and both long slider ribs,
spreading the connection beyond isolated screw pads. Set either isogrid
toggle false for a solid-skin comparison; hardware holes and magnet pockets
remain open.
Perforation reduces material and stiffness. **No load guarantee** follows
from the grid, pads, bands, or passing source tests; this still has **no lock**.

## Motion and screen clearance

Let S be the sliding bottom axle, B the fixed rear pivot, and D the
shifted plate attachment. With `theta = 90 * deployment`,
`u = (78.8 - (-80.9) - 1)/2 = 79.35`, and `L = u+1 = 80.35`:

- `h = sqrt(L*L - u*u*sin(theta)*sin(theta))`
- **`S = [78.8 - u*cos(theta) - h, 11.2]`**
- `D = S + [u*cos(theta), u*sin(theta)]`
- Local `[y,z]` maps to
  `S + [y*cos(theta)-z*sin(theta), y*sin(theta)+z*cos(theta)]`.

The negative branch keeps D.y < B.y throughout travel. Its minimum
horizontal arm projection is `sqrt(159.7) = 12.637247`; the closure
derivative in S.y is `-2*h`, avoiding a closure toggle. Lift the monitor
top by hand: slider displacement has zero angular derivative at flat.
The second arm is a redundant support; arms and through-slot require alignment.

The axle is **7.8 mm below the actual screen bottom** when vertical.
The bottom then sits at Z = 19, above the slot roof at Z = 18.4 by
**0.6 mm**. Minimum sampled screen/track clearance is also 0.6 mm over
the full sweep; minimum screen/panel clearance is 16 mm. The bottom rises
slightly initially before lowering onto the rear pads; it is not assumed
to descend monotonically. The slot has not been hidden or cut out of
the screen: it passes through the full housing below its bottom edge.

## Connections, hardware and assembly

The carrier's flat plate is 192.5 x 165 x 3 mm at default width. Its lower
edge aligns with the monitor bottom; there are **no bottom-edge magnet
tabs or holes**. All four magnet pockets open on the broad underside near
its **TOP/far end** (carrier-local +Y), away from the bottom slider lugs.
Each bottom pivot block has a continuous 172.8 mm-long reinforcing leg
running toward the **top edge of the VESA panel** (carrier-local +Y),
from the axle to `plate_end`, with **8 x 165 x 2 mm** of shared plate
material before mounting-hole cuts. These are full-length underside ribs,
not short bottom tabs; they stay below the flat monitor-contact face. Lug width,
M4 screw stack and folded height are unchanged; motion uses the shorter arms.
The four D-pivot cheek roots overlap by **8 x 16 x 2 mm** each. Four rear
feet join the panel directly. Inspect these connections after slicing,
including the isogrid voids, actual bores and VESA holes.

The two rear pads are **12 x 15 x 1.5 mm**, each providing 180 mm² of
nominal screen-bottom contact. They fit between slider hardware and arms.
Two **10 x 10 x 0.5 mm** annular stow cushions contact the plate underside
outside the slider sweep. Their **6.2 mm diameter** openings leave about
**69.8 mm²** nominal contact per cushion, not a solid 100 mm² contact face.
These are geometry contacts, not rated bearing surfaces.
`stow_pad_thickness` is separate from the unchanged rear `pad_thickness`
of 1.5 mm. The rigid pedestal tops rise to **Z = 19**, preserving contact
at **Z = 19.5** and the **37.5 mm** folded height.
`stow_lane = max(69, brace_lane + metal_thickness/2 + stow_width/2 + 0.2)`
keeps the broadened supports outside the arms: **X = ±70.2** with current
4 mm stock, ±69 with 1/1.5 mm stock, and ±69.7 with 3 mm stock.
This leaves at least 0.2 mm nominal lateral arm clearance; it is not a
manufacturing-tolerance allowance or stiffness claim.
Their rear candidate is `min(panel_rear, slider_start + plate_end)
- stow_depth/2 - stow_margin`, with a **19.4 mm** rear-edge setback.
If that candidate does not put the entire pad at least **2 mm behind**
the deployed screen, its center is clamped forward to at most
`pad_front[0] - stow_depth/2 - stow_screen_gap`, leaving **2 mm ahead**.
This retains the default rear edge with Y = 59.5..69.5. On 40 HP/5U, the
folded plate rear is Y = 69.675, moving the pads to **Y = 40.275..50.275**.
Keeping the default stow station on 5U would hit the deployed screen.
The +30 mm row-offset case uses Y = 27.862753..37.862753 instead of
the interfering unclamped station. The static endpoint guard alone is not
a continuous clearance proof; no new sweep validation is claimed here.
Rear pads continue to follow the actual deployed screen bottom.

### Post-print magnet pockets

Fit your existing **6 x 2 mm disc magnets after printing**: **eight magnets**
total, **four in the base and four in the VESA underside**. The two outer
and two inboard base magnets each have exactly one folded carrier mate.
All four existing base posts and their Z pockets are unchanged; only the
extra bottom-edge carrier tabs and their local-Y pockets were removed.
Every pocket is **6.2 mm diameter x 2.1 mm deep**, blind and accessible:

| Pocket | XY center (mm, part-local) | Z extent / insertion face (mm) |
| --- | --- | --- |
| Base, two | [±70.2, 64.5] | 16.9..19; insert downward through top at 19 |
| Carrier, two | [±70.2, 145.4] | 8.3..10.4; insert upward through underside at 8.3 |
| Inboard base, two | [±35, 60.512753] | 13.4..15.5; insert downward through top at 15.5 |
| Inboard carrier, two | [±35, 141.412753] | 4.8..6.9; insert upward through underside at 4.8 |

At stow, carrier Y shifts by -80.9 and Z by +11.2, aligning all four pairs.
Each row below maps one actual base post to its carrier pocket mouth:

| Base mouth, world XYZ (mm) | Carrier mouth, local XYZ (mm) | Folded carrier mouth, world XYZ (mm) |
| --- | --- | --- |
| [-70.2, 64.5, 19] | [-70.2, 145.4, 8.3] | [-70.2, 64.5, 19.5] |
| [+70.2, 64.5, 19] | [+70.2, 145.4, 8.3] | [+70.2, 64.5, 19.5] |
| [-35, 60.512753, 15.5] | [-35, 141.412753, 4.8] | [-35, 60.512753, 16] |
| [+35, 60.512753, 15.5] | [+35, 141.412753, 4.8] | [+35, 60.512753, 16] |

All base mouths face world +Z; all folded carrier mouths face world −Z.
Every pair has a **0.5 mm rigid-face gap** and **0.7 mm seated magnet-face
gap**. These coordinates use current **4 mm stock**; no stock input changed.
`magnet_pockets(carrier)` drives the outer cutters;
`dock_magnet_pockets()` and `dock_fold_magnet_pockets()` drive the inboard
base and underside cutters respectively.
Cuts surround each entire rigid union. The 0.01 mm Boolean extension is
only outside the opening face: it does not deepen the 2.1 mm blind seat.
The 64-facet opening has about 0.096 mm minimum radial clearance to a
round 6 mm magnet before print tolerances. No enclosed print-in-place voids,
through-holes, printed magnets or additional hardware exports are used.

Each outer pedestal has at least **1.9 mm side walls** around its pocket and
**13.9 mm** of rigid material below the seat down to the panel top.
The carrier retains a **0.9 mm roof** in its 3 mm plate and **2.7 mm**
minimum pocket-to-plate-edge ligament at current defaults. The full
10 x 10 mm carrier contact region fits within the plate; its +4 mm grid
mask clips at the existing plate edge. There are **no monitor-contact
bosses**, and the full-length underside ribs remain unchanged. The thin
roof is for adhesive-mounted discs, not a press-fit or load qualification.
Avoid drilling through it; inspect the sliced roof and print quality.

Fully seated 2 mm discs are nominally **0.1 mm recessed** from each rigid
face. With the dedicated **0.5 mm** stow cushion, the nominal magnetic
face gap is **0.7 mm**, before adhesive thickness, cushion compression and
printing variation. Reusing the 1.5 mm rear-pad thickness here would make
that gap 1.7 mm. Even 0.7 mm weakens attraction compared with touching
faces; holding force is unverified and **not a transport latch** or a
deployed-position lock. Continue supporting the assembly as described above.

Install with the parts separate, before mounting the monitor. The base
pockets are also accessible with the carrier held fully open; remove the
carrier if needed to reach its underside safely. Dry-fit the discs without
forcing them. Mark and verify **opposite poles** facing across each pair,
then bond with a thin, compatible **adhesive** layer. Keep each disc recessed,
remove squeeze-out and allow full cure before closing the mount. Bond the
separate annular elastomer cushions around, not across, the base openings;
include their bonding layer in the intended 0.5 mm installed thickness.
There is no need to pause printing or trap a magnet inside either part.

### Folded inboard docking: reinforced seats on the broad VESA underside

The two existing inboard dock pedestals serve **only the folded position**.
At fold-flat, they meet two integral bosses on the broad VESA underside.
Select `vesa_panel` and look near the **TOP/far end of its underside**, at
local **[±35, 141.412753]**, not its bottom edge: these regions are solid
reinforced seats with downward-opening circular pockets, not isogrid holes.

Each default boss is **10 x 9.3 mm** in XY and spans local **Z = 4.8..10.3**.
The footprint derives from `dock_width` / `dock_depth`; its center follows
`dock_y - slider_start`. Post depth is the 6.2 mm pocket diameter plus two
1.55 mm fore/aft walls. The post front stays 1 mm behind the deployed
screen back; its folded contact face stays 3 mm below the screen-edge stop.
These stow dimensions preserve the existing posts without depending on
removed tab dimensions. The pocket spans **Z = 4.8..6.9**, opening toward
local −Z for upward insertion. The entire boss overlaps the plate by **2 mm**
at Z = 8.3..10.3. Its complete XY footprint plus **4 mm outside each edge**
is excluded from the grid cutters. These masks preserve material; the
separate `dock_fold_magnet_pockets()` cutters subtract the actual cavities
from the complete carrier union, so no mask fills their openings.

Default pocket side walls are at least **1.55 mm** (1.9 mm in X), with
**4.4 mm** of solid roof above the blind seat up to plate top Z = 11.3.
The monitor-contact face stays flat. On 5U the folded mating station lies
beyond the rectangular plate end; each boss extends back to `plate_end - 5`
to retain at least **10 x 5 x 2 mm** of shared plate material. That local
extension stays below the monitor face and within its height; the plate,
linkage and base dimensions do not move. Where the seat projects beyond
the plate (5U and part of the lower-row variant), its own top at Z = 10.3
still leaves **3.4 mm** of blind roof.

At deployment 0, the folded translation [Y,Z] = [-80.9,11.2] places the
mouths at world **[±35, 60.512753, 16]**, directly over the existing
base mouths at **[±35, 60.512753, 15.5]**. The existing **0.5 mm** annular
dock cushions contact the solid area around each mouth. Fully seated faces
are Z = **16.1** and **15.4**, a **0.7 mm** nominal gap. At 90 degrees these
bosses rise away from the posts; no upright magnetic docking remains.
No additional cushions or magnets on the monitor itself are required.

### Retained cushions and folded-only magnet installation

The original rear **12 x 15 x 1.5 mm** cushions at X = ±54 contact the
**actual monitor bottom edge**, not the carrier. They are unchanged and
remain the exact 90-degree over-opening stops. Do not put magnets on them
or on the monitor. The removed bottom-edge tabs provide no upright stop
or magnetic retention. Support the monitor while deployed: the original
screen-edge pads stop over-opening only, not folding.

Bond two **10 x 9.3 x 0.5 mm** annular elastomer cushions to these pedestal
tops, with **6.2 mm** central openings (about **62.9 mm²** contact each).
Cut them from sheet using the pedestal footprint; the existing part selector
is unchanged. Include adhesive in their 0.5 mm installed thickness, and
keep the magnet mouths open. These cushions remain over the inboard posts
because they meet the broad underside bosses when folded. Each base post
still joins the panel with 0.5 mm overlap and has **10.4 mm** of material
below the pocket floor above the panel top.

**Install all eight magnets with the printed parts separate, before mounting
the monitor or assembling the linkage.** All four carrier pockets are
reached from the broad underside, never from the bottom edge or through
the monitor-contact face. Each base magnet attracts one carrier magnet.
Verify opposite poles facing across **each of the four folded pairs**
before bonding; there is no second, upright mate to fit or align.
Adhesive-bond each disc separately, remove squeeze-out and cure
fully before trial motion. No press fits or captured print-in-place magnets.

Magnet grade, adhesive, actual recess and cushion compression determine
attraction. Measure it experimentally with the monitor supported; **no
holding-force, load, transport-latch or deployed-lock rating is claimed**.
Inspect boss roots, thin walls and layer orientation before fitting hardware.

| Qty | Hardware | Nominal geometry |
| --- | --- | --- |
| 2 | Metal arms | 80.35 mm hole spacing, 12 mm wide, 4 mm stock |
| 8 | Disc magnets, individually adhesive bonded | 6 mm diameter x 2 mm; four base, four carrier; four folded pairs |
| 2 | Annular stow cushions | 10 x 10 x 0.5 mm, 6.2 mm opening |
| 2 | Annular inboard stow cushions | 10 x 9.3 x 0.5 mm, 6.2 mm opening |
| 2 | Original rear screen-edge cushions | 12 x 15 x 1.5 mm; unchanged |
| 4 each | M5 arm bolts and retained nuts | 5.4 mm bores, double cheeks |
| 8 | Pivot washers | 9 OD x 5.4 ID x 1 mm |
| 1 | M4x45 screw, preferably fully threaded | 4 mm shaft; 45 mm under head; head 7 OD x 4 mm |
| 2 | External M4 washers | 9 OD x 4.3 ID x 0.8 mm, head and nut sides |
| 1 | M4 nyloc locknut | 7 mm across flats, 5 mm thick |
| 2 | Monitor screws | Manufacturer-approved type and engagement |
| 4 | Panel fasteners | Match the API's 3.5 mm holes |

### Single-screw width budget and retention

The under-head to nut outer-face stack is **43.6 mm**, strictly below
45 mm: **20 mm block + 2 x 8 mm lugs + 2 x 0.5 mm running gaps +
2 x 0.8 mm external washers + 5 mm locknut = 43.6 mm**.
This includes **two 0.8 mm washers** and a **5 mm M4 nyloc**. The screw
leaves **1.4 mm** beyond the nut: two nominal 0.7 mm M4 thread pitches.
The head is excluded from the 45 mm screw-length convention; the entire
screw, including its 4 mm head, is 49 mm long.

| Slider hardware | Absolute X interval (mm) |
| --- | --- |
| Screw shaft (one piece) | -19.3..25.7 |
| Head, extending toward negative X | -23.3..-19.3 |
| Head-side washer | -19.3..-18.5 |
| Nut-side washer | 18.5..19.3 |
| Locknut | 19.3..24.3 |

This asymmetric hardware set is rendered **once**, not mirrored. The
locknut is a real preview ring with a 2.1 mm bore radius and conservative
circular outer envelope of radius `7/sqrt(3)` mm for the 7 mm AF hex.
That bore is thread relief, not a tap-drill size; threads and nylon are
not modeled. Both lug bores and the full-width slot are 4.5 mm diameter.
Nominal radial shaft clearance is 0.25 mm; the inscribed 48-facet opening
leaves about 0.245 mm clearance to a conservative round 4 mm shaft.

The lugs straddle the housing with a **0.5 mm running gap on each side**.
Their 16 mm diameter cannot pass through the slot, limiting lateral play.
The closed roof, floor and slot ends retain the shaft in YZ even without
the arms. There is no compression spacer: **snug adjustment only, never
structural torque**. Tightening the nut hard could flex the carrier and
clamp away both running gaps, binding the slider. Keep the washers at
the lug outer faces without drawing the lugs inward; verify free motion
and both gaps after adjustment. The nyloc retains its adjustment; it is
not a motion lock or counterbalance.

The nominal budget has no spare manufacturing allowance beyond the two
pitches. Measure the actual screw under-head length, tip chamfer, washers,
lug spacing and nut height; verify full nylon engagement and at least
1.4 mm usable thread protrusion. The guard's 1e-8 mm tolerance is only for
floating-point arithmetic, not permission to accept an undersized stack
margin. Reject hardware that fails this check. A threaded shaft bearing
directly on the slot can accelerate wear; this remains an un-rated prototype.
Arm clevis gaps remain stock thickness plus two 1 mm washers.

1. Prepare the base and carrier, without arms, pivot screws or monitor.
  Install magnets and bonded cushions as above; let adhesive cure.
  There are no slot-end caps to remove.
2. **Lower and align the flat carrier first**, at the **front** station
  Y = -80.9, Z = 11.2. Its two lugs straddle the housing; align both
  lug bores with the slot. A pre-inserted screw blocks this lowering path.
3. Place the head-side washer on the screw, then insert along **+X** through
  the **first lug**, full-width slot and **second lug**. The head/washer
  stay outside the first lug; the rear feet do not obstruct this path.
4. Slide the other washer onto the protruding end and thread on the nyloc
  from positive X. Snug-adjust as above, preserving both running gaps.
5. Fit arms, washers and retained M5 pivots. Trial the supported motion,
   then fit the monitor using approved screws and check cable slack.

## Exports and validation

`part`: `assembly`, `poses` (0/45/90), `makerpanel`, `vesa_panel`,
`brace`, `brace_2d`, `slider_bolt`, `slider_washer`, `slider_locknut`,
`pivot_washer`, `rear_pad`, `stow_pad`. `slider_washer` exports one washer;
assembly uses two. Shoe and motion-lock exports are removed. Hardware
exports are references, not instructions to print metal substitutes.
Existing user-created STL/GLB/SVG exports are untouched; they have not been
regenerated from this revision.

`part = "makerpanel"` selects only the 3D mounting/measuring base, in
the same coordinates as the base in `assembly`. The implementation module
remains `maker_panel()` to avoid colliding with the library's `makerpanel()`.

`monitor.test.cjs` is absent from the current working tree. No deleted suite
was restored or recreated, and no previous suite pass is claimed here.
Lightweight inline Node validation in native Windows PowerShell checks the
current source declarations, rendered geometry-table records and cutter
transforms: eight pockets, four folded XY matches, opposing ±Z mouth
normals, 0.5 mm rigid-face / 0.7 mm magnet-face gaps, and unchanged 0/90
motion endpoints. The pre-edit working source is the comparison baseline,
not a historical test oracle. No test or probe files are written.

The change removes two carrier tabs, their root masks and local-Y cutters;
the four base posts, all retained Z pockets, folded bosses, cushions and
kinematics remain unchanged. This removal does not enlarge the moving
solid envelope. It is not a new collision sweep, compiled CSG validation,
mesh-connectivity check or strength proof. Editor diagnostics and
`git diff --check` cover source issues and whitespace, not rendered geometry.
URDF screenshot validation is handled separately; no rendered confirmation
is claimed for this edit. Physical stability and magnetic holding force
remain unverified.
Prototype slot wear/alignment, housing and thin-plate stiffness, arm
bending, offset-monitor torsion, screw bending, thread wear and fastener retention
before loading. Two-screw monitor mounting requires manufacturer approval.

## MakerPanel compatibility

The [API](../../makerpanel/common.scad) uses 5.08 mm/HP and 44.45 mm/U,
giving a 177.8 x 177.8 mm 35 HP/4U panel. The
[specification](../../docs/specification.md) distinguishes 128.5 mm 3U
panel height from 133.35 mm unit spacing; API compatibility is preserved.
API mounting bores are 3.5 mm, not M5 clearance. Mounting-hole access is
retained. The flush housing intentionally reaches the panel end planes,
rather than maintaining the specification's 2 mm edge setback there.
The rear screen/plate overhang and deployed height are documented custom
extensions, not a whole-assembly compliance claim.
