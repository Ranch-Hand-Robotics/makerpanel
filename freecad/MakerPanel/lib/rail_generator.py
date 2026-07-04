"""rail_generator.py — MakerRail 2D sketch generator.

Creates a FreeCAD sketch of a MakerRail flat layout on the XY plane of the
supplied document.

Rail cross-beam flat layout (origin at bottom-left):

              Rail
             Height (11mm)            < Slot width: 19.125mm >
            <  |   >
    ↑       ┌───────────────────────────────────────────────────────────────────┐
            │      ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │      ↑
Rail Height │  0   │               │  │               │  │               │  0   │  Slot Height
            │      └───────────────┘  └───────────────┘  └───────────────┘      │  6.9mm
    ↓       └───────────────────────────────────────────────────────────────────┘      ↓
                                   <  >
                                  Support
                               Width: 3.0mm
                   < --------- 44.45mm (1U) --------->
                   (Support + Slot + Support + Slot)

All coordinates are in millimetres.
"""

from __future__ import annotations

import math

import FreeCAD
import Part

from . import const


def create_makerrail_sketch(
    doc,
    width_hp,
    rail_height_mm,
    custom_length_mm=None,
    add_end_holes=True,
    hole_diameter_mm=3.5,
    rotate90=False,
):
    """Create a 2D MakerRail sketch on the document XY plane.

    Args:
        doc:               Target FreeCAD document.
        width_hp:          Rail length in HP units (1 HP = 5.08 mm).
        rail_height_mm:    Physical height of the rail strip in mm.
        custom_length_mm:  Optional override for total rail length in mm.
        add_end_holes:     When True, mounting holes are added in the end supports.
        hole_diameter_mm:  Clearance hole diameter in mm.
        rotate90:          When True, the rail is drawn vertically.

    Returns:
        The FreeCAD Sketcher::SketchObject containing the rail geometry.
    """
    if doc is None:
        raise ValueError("An active FreeCAD document is required.")
    if width_hp < 1:
        raise ValueError("Rail width must be at least 1 HP.")
    if rail_height_mm <= 0:
        raise ValueError("Rail height must be positive.")

    rail_length = float(custom_length_mm) if custom_length_mm is not None else float(width_hp) * const.HP_UNIT
    rail_height = float(rail_height_mm)
    if rail_length <= 0:
        raise ValueError("Rail length must be positive.")

    sketch = _new_sketch(doc, "MakerRailSketch", f"MakerRail {width_hp}HP x {rail_height_mm:.3f}mm")

    if rotate90:
        _add_rectangle(sketch, 0.0, 0.0, rail_height, rail_length)
    else:
        _add_rectangle(sketch, 0.0, 0.0, rail_length, rail_height)

    _add_rail_slots(sketch, rail_length, rail_height, add_end_holes, rotate90)

    if add_end_holes:
        _add_end_holes(sketch, rail_length, rail_height, float(hole_diameter_mm), rotate90)

    doc.recompute()
    return sketch


def _new_sketch(doc, name, label):
    """Create a new sketch object anchored to the global XY plane."""
    sketch = doc.addObject("Sketcher::SketchObject", name)
    sketch.Label = label
    sketch.Placement = FreeCAD.Placement()
    return sketch


def _add_rail_slots(sketch, rail_length, rail_height, add_end_holes, rotate90):
    """Draw rounded rectangular slot cut-outs centred vertically in the rail."""
    min_slot_width = const.RAIL_SLOT_MIN_WIDTH
    slot_height = const.RAIL_SLOT_HEIGHT
    support_width = const.RAIL_SUPPORT_WIDTH

    end_margin = rail_height if add_end_holes else support_width
    available = rail_length - 2.0 * end_margin
    min_pitch = min_slot_width + support_width
    slot_count = int((available + support_width) / min_pitch)
    if slot_count < 1:
        slot_count = 1 if available > 0 else 0
    if slot_count == 0:
        return

    actual_slot_width = (available - (slot_count - 1) * support_width) / slot_count
    if actual_slot_width <= 0:
        return

    slot_bottom = (rail_height - slot_height) / 2.0
    slot_top = slot_bottom + slot_height

    if rotate90:
        slot_left = (rail_height - slot_height) / 2.0
        slot_right = slot_left + slot_height
        position = end_margin
        for _ in range(slot_count):
            _draw_rounded_rect(sketch, slot_left, position, slot_right, position + actual_slot_width)
            position += actual_slot_width + support_width
    else:
        position = end_margin
        for _ in range(slot_count):
            _draw_rounded_rect(sketch, position, slot_bottom, position + actual_slot_width, slot_top)
            position += actual_slot_width + support_width


def _add_end_holes(sketch, rail_length, rail_height, hole_diameter_mm, rotate90):
    """Add circular mounting holes centred in the end margins."""
    hole_radius = hole_diameter_mm / 2.0
    centre_offset = rail_height / 2.0

    left_pos = rail_height / 2.0
    right_pos = rail_length - rail_height / 2.0

    if rotate90:
        _draw_circle(sketch, centre_offset, left_pos, hole_radius)
        _draw_circle(sketch, centre_offset, right_pos, hole_radius)
    else:
        _draw_circle(sketch, left_pos, centre_offset, hole_radius)
        _draw_circle(sketch, right_pos, centre_offset, hole_radius)


def _draw_rounded_rect(sketch, x1, y1, x2, y2):
    """Draw a rounded rectangle using four lines and four quarter arcs."""
    radius = min(
        const.RAIL_SLOT_CORNER_RADIUS,
        abs(x2 - x1) / 2.0,
        abs(y2 - y1) / 2.0,
    )
    if radius <= 0:
        return

    _add_line(sketch, x1 + radius, y1, x2 - radius, y1)
    _add_arc(sketch, x2 - radius, y1 + radius, radius, -math.pi / 2.0, 0.0)
    _add_line(sketch, x2, y1 + radius, x2, y2 - radius)
    _add_arc(sketch, x2 - radius, y2 - radius, radius, 0.0, math.pi / 2.0)
    _add_line(sketch, x2 - radius, y2, x1 + radius, y2)
    _add_arc(sketch, x1 + radius, y2 - radius, radius, math.pi / 2.0, math.pi)
    _add_line(sketch, x1, y2 - radius, x1, y1 + radius)
    _add_arc(sketch, x1 + radius, y1 + radius, radius, math.pi, 3.0 * math.pi / 2.0)


def _add_rectangle(sketch, x1, y1, x2, y2):
    """Draw a closed rectangle using four line segments."""
    _add_line(sketch, x1, y1, x2, y1)
    _add_line(sketch, x2, y1, x2, y2)
    _add_line(sketch, x2, y2, x1, y2)
    _add_line(sketch, x1, y2, x1, y1)


def _draw_circle(sketch, cx, cy, radius):
    """Draw a circle at ``(cx, cy)``."""
    sketch.addGeometry(
        Part.Circle(
            FreeCAD.Vector(cx, cy, 0.0),
            FreeCAD.Vector(0.0, 0.0, 1.0),
            radius,
        ),
        False,
    )


def _add_line(sketch, x1, y1, x2, y2):
    """Append a line segment to a sketch."""
    sketch.addGeometry(
        Part.LineSegment(
            FreeCAD.Vector(x1, y1, 0.0),
            FreeCAD.Vector(x2, y2, 0.0),
        ),
        False,
    )


def _add_arc(sketch, cx, cy, radius, start_angle, end_angle):
    """Append an arc of a circle to a sketch."""
    sketch.addGeometry(
        Part.ArcOfCircle(
            Part.Circle(
                FreeCAD.Vector(cx, cy, 0.0),
                FreeCAD.Vector(0.0, 0.0, 1.0),
                radius,
            ),
            start_angle,
            end_angle,
        ),
        False,
    )
