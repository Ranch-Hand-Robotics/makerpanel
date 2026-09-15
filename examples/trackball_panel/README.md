---
title: Trackball Panel
category: Input
description: >-
  Meishi trackball MakerPanel
---

# Trackball MakerPanel

A panel for an underside-mounted meishi trackball module. Four module
holes are reconstructed as native OpenSCAD circles from the supplied
`meishi_trackball_module_bottom.pdf`; the PDF is not needed to render the model.
The MakerPanel library supplies the four separate rail mounting holes.

## Extracted dimensions

The PDF has one vector-only page, with a 172.92 × 274.92 point MediaBox and no
custom UserUnit or page rotation. Measurements use **25.4 / 72 mm per point**,
not a screenshot or a fit-to-page printout. Physical fit assumes the drawing
was authored at 1:1; verify one hole spacing on the hardware before fabrication.

| Feature | Nominal measurement |
| --- | --- |
| Module/bottom-plate outline | 55 × 91 mm |
| Outline corner radius | 2.1 mm |
| Horizontal hole spacing | 50.8 mm |
| Vertical hole spacing | 86.8 mm |
| Four hole diameters | 2.2 mm |
| Hole centers, relative to outline center | X = ±25.4, Y = ±43.4 mm |

Extraction identified four small stroked closed paths, one stroked exterior
path, two center-mark strokes, and three filled graphic paths. Only the four
corner paths become holes. The central graphic and center marks are **not**
cutouts.

The PDF hole centers in page points are X = 14.46 / 158.46 and
Y = 14.436378 / 260.483622. Subtract the outline center
(86.46, 137.46), convert to millimeters, and reverse Y for OpenSCAD.
Hole diameters and outline dimensions use the curve endpoints, not the
stroke thickness or control-point bounding boxes. The PDF uses slightly
noncircular cubic curves; the SCAD intentionally reconstructs nominal circles
and a rounded rectangle rather than reproducing those small curve deviations.

## Panel and exports

Open `trackball_panel.scad`. Includes are relative to this example, so no
additional OpenSCAD library search path is required.

- Default: **18 HP × 4U**, **91.44 × 177.8 × 3 mm**.
- `horizontalPitch` and `verticalUnits`: panel dimensions using the library.
  Smaller panels may require reducing the trackball's upward offset.
- `panelThickness`: plate thickness; select suitable material and rigidity.
- `holeClearance`: additional diameter for the four module holes only.
  Default zero preserves the PDF's 2.2 mm. It does not move their centers.
- `openingWidth`: rectangular opening width, default **54 mm**.
- `openingInset`: distance from the top and bottom bolt-row centerlines
  inward to the opening edges. Default **3 mm** gives an **80.8 mm** height.
- `trackballOffsetY`: moves the opening, four module mounting holes, and
  assembly footprint **20 mm toward the panel top (+Y)** by default.
  The panel outline and rail mounting holes remain fixed.
  The **54 × 80.8 mm** through-opening spans X = −27…27 mm and
  Y = −20.4…60.4 mm; the module bolt rows are at Y = −23.4 and 63.4 mm.
- `part = "makerpanel"`: 3D mounting/measuring plate, with eight mounting holes
  and the rectangular through-opening.
- `part = "panel_2d"`: the same profile for SVG/DXF laser-cutting export.
- `part = "assembly"`: panel with a preview-only, 0.5 mm-thick footprint
  beneath it. This is **not** a dimensional model of the complete trackball.
- `part = "footprint"`: nominal 2D source outline and original hole pattern,
  useful for a 1:1 paper fit check. This is not the MakerPanel export.

Assertions reject panel sizes that leave less than 2 mm around the module,
place its holes too close to a panel edge or rail hole, or obstruct rail holes
with the module footprint. Actual screw-head/tool access depends on hardware.
Opening checks require positive dimensions and material between the opening
and the top/bottom bolt holes. The default 3 mm centerline setback leaves
**1.9 mm** from the opening to each 2.2 mm hole edge; check screw-head support.

## Mounting assumptions

The module mounts **under** the panel, using its four corner mounting points.
The rectangular opening exposes its center while retaining all four mounts.
Its 3 mm vertical inset is measured from bolt-row centers, not the exterior
module outline or hole edges. The 54 mm width is independent of the bolt
spacing; this opening is a design choice, not a feature from the PDF.
The full footprint is not subtracted: doing so would remove the supporting
material at those mounting points. Check actual ball/housing clearance through
the opening: the bottom drawing does not establish the upper housing profile.
No separate cable opening, counterbore, or PCB recess is inferred.

Use hardware compatible with the module's existing mounting points; the
2.2 mm drawing holes suggest M2 clearance but do not establish thread size.
Select screws and, if needed, insulating standoffs after checking the actual
PCB underside, connector access, original bottom plate, and fastener lengths.
Confirm that the corner mounts accept fasteners from above and use suitable
spacers to clear the upper housing as needed. No electronics or fasteners
are modeled. The PDF does not establish assembled height or depth, so the
60 mm system depth limit cannot be certified from this drawing alone.

## Specification compatibility

This example uses the existing library's HP units, 3.5 mm rail screw holes,
and 5.5 mm corner insets, retaining its MakerRail/T-nut interface. The module's
2.2 mm holes are a separate component-specific mounting pattern, not M3 rail
holes.

The [written specification](../../docs/specification.md) lists a 128.5 mm
3U faceplate, but `makerpanel_2d()` uses `u_to_mm(3) = 133.35 mm`. This example
preserves the current geometry API rather than silently changing rail
alignment. The 2.5U option is a custom height allowed by the specification.