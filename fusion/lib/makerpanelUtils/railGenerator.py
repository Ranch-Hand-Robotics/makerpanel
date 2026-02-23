"""
railGenerator.py — MakerRail 2D sketch generator.

Creates a parametric Fusion 360 sketch of a MakerRail flat layout on
the XY plane of the supplied component.


Rail cross-beam flat layout (origin at bottom-left):

              Rail 
             Height (11mm)            < Slot width: 19.125mm >
            <  |   >                   
    ↑       ┌───────────────────────────────────────────────────────────────────┐
            │      ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │      ↑
Rail Height │  0   │               │  │               │  │               │  0   │  Slot Height
            │      └───────────────┘  └───────────────┘  └───────────────┘      │  6.2mm
    ↓       └───────────────────────────────────────────────────────────────────┘      ↓
                                   <  >
                                  Support
                               Width: 6.2mm
                   < --------- 44.45mm (1U) --------->
                   (Support + Slot + Support + Slot)

All coordinates in centimetres (Fusion 360 internal unit).
"""

import math
import adsk.core
import adsk.fusion

from . import const


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def createMakerRailSketch(
    component: adsk.fusion.Component,
    widthHp: int,
    railHeightMm: float,
    customLengthMm: float = None,
    addEndHoles: bool = True,
    holeDiameterMm: float = 3.5,
    rotate90: bool = False,
) -> adsk.fusion.Sketch:
    """Create a 2D MakerRail sketch on the component's XY plane.

    Args:
        component:      Target Fusion 360 component.
        widthHp:        Rail length in HP units (1 HP = 5.08 mm). Used to
                        compute the default total length.
        railHeightMm:   Physical height of the rail strip in mm.
        customLengthMm: Optional override for total rail length in mm.
        addEndHoles:    When True, mounting holes are added in the end supports.
        holeDiameterMm: Clearance hole diameter in mm (default 3.5 mm = M3).
        rotate90:       When True, the rail is drawn vertically (length along Y axis).

    Returns:
        The newly created adsk.fusion.Sketch object.
    """
    if customLengthMm is not None:
        rail_length = customLengthMm / 10.0
    else:
        rail_length = widthHp * const.HP_UNIT  # cm

    rail_height = railHeightMm / 10.0  # mm → cm

    sketch = component.sketches.add(component.xYConstructionPlane)
    sketch.name = f'MakerRail {widthHp}HP x {railHeightMm:.1f}mm'

    # Outer rectangle — if rotate90, length runs along Y axis instead of X
    if rotate90:
        sketch.sketchCurves.sketchLines.addTwoPointRectangle(
            adsk.core.Point3D.create(0, 0, 0),
            adsk.core.Point3D.create(rail_height, rail_length, 0),
        )
    else:
        sketch.sketchCurves.sketchLines.addTwoPointRectangle(
            adsk.core.Point3D.create(0, 0, 0),
            adsk.core.Point3D.create(rail_length, rail_height, 0),
        )

    _add_rail_slots(sketch, rail_length, rail_height, addEndHoles, rotate90)

    if addEndHoles:
        _add_end_holes(sketch, rail_length, rail_height, holeDiameterMm / 10.0, rotate90)

    return sketch


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

def _add_rail_slots(sketch, rail_length, rail_height, add_end_holes, rotate90):
    """Draw rounded rectangular slot cutouts centred vertically in the rail.

    Mirrors rails.scad maker_rail_2d:
      - add_end_holes=True:  end margin = rail_height, available = rail_length - 2*rail_height
      - add_end_holes=False: end margin = support_w,   available = rail_length - 2*support_w
      - num_slots = floor((available + support_w) / (min_slot_w + support_w))
      - actual_slot_w = (available - (num_slots-1) * support_w) / num_slots
    When rotate90=True, slots run along the Y axis (rail is vertical).
    """
    min_slot_w = const.RAIL_SLOT_MIN_WIDTH
    slot_h     = const.RAIL_SLOT_HEIGHT
    support_w  = const.RAIL_SUPPORT_WIDTH
    r          = const.RAIL_SLOT_CORNER_RADIUS

    end_margin = rail_height if add_end_holes else support_w
    available  = rail_length - 2 * end_margin
    min_pitch  = min_slot_w + support_w
    num_slots  = int((available + support_w) / min_pitch)
    if num_slots < 1:
        num_slots = 1
    actual_slot_w = (available - (num_slots - 1) * support_w) / num_slots

    slot_y_bot = (rail_height - slot_h) / 2.0
    slot_y_top = slot_y_bot + slot_h

    if rotate90:
        # Slots run along Y — narrow band centred on X, advancing in Y
        slot_x_bot = (rail_height - slot_h) / 2.0
        slot_x_top = slot_x_bot + slot_h
        y = end_margin
        for _ in range(num_slots):
            _draw_rounded_rect(sketch, slot_x_bot, y, slot_x_top, y + actual_slot_w, r)
            y += actual_slot_w + support_w
    else:
        x = end_margin  # first slot starts at end_margin from left edge
        for _ in range(num_slots):
            _draw_rounded_rect(sketch, x, slot_y_bot, x + actual_slot_w, slot_y_top, r)
            x += actual_slot_w + support_w


def _add_end_holes(sketch, rail_length, rail_height, hole_diameter_cm, rotate90):
    """Add circular mounting holes centred in the end margins (width = rail_height)."""
    hole_radius = hole_diameter_cm / 2.0
    y_centre    = rail_height / 2.0

    x_left  = rail_height / 2.0
    x_right = rail_length - rail_height / 2.0

    circles = sketch.sketchCurves.sketchCircles
    if rotate90:
        circles.addByCenterRadius(
            adsk.core.Point3D.create(y_centre, x_left,  0), hole_radius)
        circles.addByCenterRadius(
            adsk.core.Point3D.create(y_centre, x_right, 0), hole_radius)
    else:
        circles.addByCenterRadius(
            adsk.core.Point3D.create(x_left,  y_centre, 0), hole_radius)
        circles.addByCenterRadius(
            adsk.core.Point3D.create(x_right, y_centre, 0), hole_radius)


def _draw_rounded_rect(sketch, x1, y1, x2, y2, r):
    """Draw a single closed rounded-rectangle profile (4 lines + 4 quarter arcs).

    Traverses CCW: bottom → BR arc → right → TR arc → top → TL arc → left → BL arc.
    Each arc uses +90° (CCW) sweep. Requires r < (x2-x1)/2 and r < (y2-y1)/2.
    """
    lines = sketch.sketchCurves.sketchLines
    arcs  = sketch.sketchCurves.sketchArcs

    # Bottom edge
    lines.addByTwoPoints(
        adsk.core.Point3D.create(x1 + r, y1, 0),
        adsk.core.Point3D.create(x2 - r, y1, 0))
    # Bottom-right arc: start (x2-r, y1) → end (x2, y1+r)
    arcs.addByCenterStartSweep(
        adsk.core.Point3D.create(x2 - r, y1 + r, 0),
        adsk.core.Point3D.create(x2 - r, y1,     0),
        math.pi / 2)
    # Right edge
    lines.addByTwoPoints(
        adsk.core.Point3D.create(x2, y1 + r, 0),
        adsk.core.Point3D.create(x2, y2 - r, 0))
    # Top-right arc: start (x2, y2-r) → end (x2-r, y2)
    arcs.addByCenterStartSweep(
        adsk.core.Point3D.create(x2 - r, y2 - r, 0),
        adsk.core.Point3D.create(x2,     y2 - r, 0),
        math.pi / 2)
    # Top edge
    lines.addByTwoPoints(
        adsk.core.Point3D.create(x2 - r, y2, 0),
        adsk.core.Point3D.create(x1 + r, y2, 0))
    # Top-left arc: start (x1+r, y2) → end (x1, y2-r)
    arcs.addByCenterStartSweep(
        adsk.core.Point3D.create(x1 + r, y2 - r, 0),
        adsk.core.Point3D.create(x1 + r, y2,     0),
        math.pi / 2)
    # Left edge
    lines.addByTwoPoints(
        adsk.core.Point3D.create(x1, y2 - r, 0),
        adsk.core.Point3D.create(x1, y1 + r, 0))
    # Bottom-left arc: start (x1, y1+r) → end (x1+r, y1)
    arcs.addByCenterStartSweep(
        adsk.core.Point3D.create(x1 + r, y1 + r, 0),
        adsk.core.Point3D.create(x1,     y1 + r, 0),
        math.pi / 2)
