"""panel_generator.py — MakerPanel 2D sketch generator.

Creates a FreeCAD sketch of a MakerPanel outline on the XY plane of the
supplied document. All coordinates are in millimetres.

Panel layout (origin at centre):

    ┌──────── panel_width ────────┐  ← y = +panel_height/2
    │  ●══════●        ●══════●   │  ← top mounting slots
    │                             │
    │       (empty face)          │
    │                             │
    │  ●══════●        ●══════●   │  ← bottom mounting slots
    └─────────────────────────────┘  ← y = -panel_height/2
   x=-panel_width/2          x=+panel_width/2

● = semicircular arc cap, ═══ = straight slot edge.
"""

from __future__ import annotations

import math

import FreeCAD
import Part

from . import const


def create_makerpanel_sketch(
    doc,
    width_hp,
    height_mm,
    add_mounting_slots=True,
    slot_style="oblong",
    minimal_mounting=False,
):
    """Create a 2D MakerPanel sketch on the document XY plane.

    Args:
        doc:                Target FreeCAD document.
        width_hp:           Panel width in HP units (1 HP = 5.08 mm).
        height_mm:          Panel height in mm.
        add_mounting_slots: When True, T-slot mounting features are added.
        slot_style:         'oblong' for elongated adjustment slots;
                            'circle' for standard circular clearance holes.
        minimal_mounting:   When True, only left edge, right edge, and centre
                            mounting features are placed instead of a full row
                            at every 25 mm interval.

    Returns:
        The FreeCAD Sketcher::SketchObject containing the panel geometry.
    """
    if doc is None:
        raise ValueError("An active FreeCAD document is required.")
    if width_hp < 1:
        raise ValueError("Panel width must be at least 1 HP.")
    if height_mm <= 0:
        raise ValueError("Panel height must be positive.")

    panel_width = float(width_hp) * const.HP_UNIT
    panel_height = float(height_mm)

    ox = -panel_width / 2.0
    oy = -panel_height / 2.0

    sketch = _get_active_sketch(doc)
    if sketch is None:
        sketch = _new_sketch(doc, "MakerPanelSketch", f"MakerPanel {width_hp}HP x {height_mm:.3f}mm")

    _add_rectangle(sketch, ox, oy, ox + panel_width, oy + panel_height)

    if add_mounting_slots:
        _add_mounting_features(
            sketch,
            panel_width,
            panel_height,
            slot_style,
            ox,
            oy,
            minimal=minimal_mounting,
        )

    doc.recompute()
    return sketch


def _get_active_sketch(doc):
    """Return the sketch currently being edited in the active GUI document."""
    try:
        import FreeCADGui as Gui
    except ImportError:
        return None

    gui_doc = getattr(Gui, "ActiveDocument", None)
    if gui_doc is None or not hasattr(gui_doc, "getInEdit"):
        return None

    in_edit = gui_doc.getInEdit()
    if not in_edit:
        return None

    candidate = in_edit[0] if isinstance(in_edit, tuple) else getattr(in_edit, "Object", in_edit)
    if (
        candidate is not None
        and getattr(candidate, "Document", None) is doc
        and getattr(candidate, "TypeId", "") == "Sketcher::SketchObject"
    ):
        return candidate
    return None


def _new_sketch(doc, name, label):
    """Create a new sketch object anchored to the global XY plane."""
    sketch = doc.addObject("Sketcher::SketchObject", name)
    sketch.Label = label
    sketch.Placement = FreeCAD.Placement()
    return sketch


def _add_mounting_features(sketch, panel_width, panel_height, style, ox, oy, minimal=False):
    """Add mounting holes or oblong slots at the top and bottom of the panel."""
    hole_radius = const.PANEL_MOUNTING_HOLE_DIAMETER / 2.0
    half_extent = hole_radius + const.PANEL_MOUNTING_SLOT_EXTRA

    y_from_edge = const.PANEL_MIN_EDGE_CLEARANCE + hole_radius
    y_bottom = oy + y_from_edge
    y_top = oy + panel_height - y_from_edge

    if y_top <= y_bottom:
        y_bottom = oy + panel_height / 2.0
        y_top = None

    if minimal:
        x_positions = _mounting_x_positions_minimal(panel_width, half_extent, ox)
    else:
        x_positions = _mounting_x_positions(panel_width, half_extent, ox)

    for x_pos in x_positions:
        if style == "oblong":
            _draw_oblong_slot(sketch, x_pos, y_bottom, half_extent, hole_radius)
            if y_top is not None:
                _draw_oblong_slot(sketch, x_pos, y_top, half_extent, hole_radius)
        else:
            _draw_circle(sketch, x_pos, y_bottom, hole_radius)
            if y_top is not None:
                _draw_circle(sketch, x_pos, y_top, hole_radius)


def _mounting_x_positions_minimal(panel_width, half_extent, ox):
    """Return X positions for minimal mounting: left edge, centre, right edge."""
    edge_offset = const.PANEL_MIN_EDGE_CLEARANCE + half_extent
    left_x = ox + edge_offset
    right_x = ox + panel_width - edge_offset
    mid_x = ox + panel_width / 2.0

    if right_x <= left_x:
        return [mid_x]

    positions = [left_x]
    if abs(mid_x - left_x) > 1.0 and abs(mid_x - right_x) > 1.0:
        positions.append(mid_x)
    positions.append(right_x)
    return positions


def _mounting_x_positions(panel_width, half_extent, ox):
    """Return X centre positions for a full-width mounting pattern."""
    edge_offset = const.PANEL_MIN_EDGE_CLEARANCE + half_extent

    left_x = ox + edge_offset
    right_x = ox + panel_width - edge_offset

    if right_x <= left_x:
        return [ox + panel_width / 2.0]

    span = right_x - left_x
    gap_count = max(1, round(span / const.PANEL_MOUNTING_HOLE_SPACING))
    return [left_x + index * span / gap_count for index in range(gap_count + 1)]


def _add_rectangle(sketch, x1, y1, x2, y2):
    """Draw a closed rectangle using four line segments."""
    _add_line(sketch, x1, y1, x2, y1)
    _add_line(sketch, x2, y1, x2, y2)
    _add_line(sketch, x2, y2, x1, y2)
    _add_line(sketch, x1, y2, x1, y1)


def _draw_oblong_slot(sketch, cx, cy, half_extent, radius):
    """Draw a pill-shaped slot centred at ``(cx, cy)``."""
    track_half = half_extent - radius
    if track_half <= 0:
        _draw_circle(sketch, cx, cy, radius)
        return

    left_x = cx - track_half
    right_x = cx + track_half

    _add_line(sketch, left_x, cy + radius, right_x, cy + radius)
    _add_arc(sketch, right_x, cy, radius, -math.pi / 2.0, math.pi / 2.0)
    _add_line(sketch, right_x, cy - radius, left_x, cy - radius)
    _add_arc(sketch, left_x, cy, radius, math.pi / 2.0, 3.0 * math.pi / 2.0)


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
