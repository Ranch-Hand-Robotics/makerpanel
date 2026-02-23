"""
panelGenerator.py — MakerPanel 2D sketch generator.

Creates a parametric Fusion 360 sketch of a MakerPanel outline on the XY
plane of the supplied component.  All coordinates are in centimetres (Fusion
360 internal length unit).

Panel layout (origin at bottom-left):

    ┌──────── panel_width ────────┐  ← y = panel_height
    │  ●══════●        ●══════●  │  ← top mounting slots
    │                             │
    │       (empty face)          │
    │                             │
    │  ●══════●        ●══════●  │  ← bottom mounting slots
    └─────────────────────────────┘  ← y = 0
   x=0                          x=panel_width

● = semicircular arc cap, ═══ = straight slot edge.
"""

import math
import adsk.core
import adsk.fusion

from . import const


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def createMakerPanelSketch(
    component: adsk.fusion.Component,
    widthHp: int,
    heightMm: float,
    addMountingSlots: bool = True,
    slotStyle: str = 'oblong',
) -> adsk.fusion.Sketch:
    """Create a 2D MakerPanel sketch on the component's XY plane.

    Args:
        component:        Target Fusion 360 component.
        widthHp:          Panel width in HP units (1 HP = 5.08 mm).
        heightMm:         Panel height in mm.
        addMountingSlots: When True, T-slot mounting features are added.
        slotStyle:        'oblong' → elongated adjustment slots (default);
                          'circle' → standard circular clearance holes.

    Returns:
        The newly created adsk.fusion.Sketch object.
    """
    panel_width  = widthHp * const.HP_UNIT  # cm
    panel_height = heightMm / 10.0           # mm → cm

    sketch = component.sketches.add(component.xYConstructionPlane)
    sketch.name = f'MakerPanel {widthHp}HP x {heightMm:.1f}mm'

    # Outer panel boundary
    sketch.sketchCurves.sketchLines.addTwoPointRectangle(
        adsk.core.Point3D.create(0, 0, 0),
        adsk.core.Point3D.create(panel_width, panel_height, 0),
    )

    if addMountingSlots:
        _add_mounting_features(sketch, panel_width, panel_height, slotStyle)

    return sketch


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

def _add_mounting_features(sketch, panel_width, panel_height, style):
    """Add mounting holes or oblong slots at the top and bottom of the panel."""
    hole_radius = const.PANEL_MOUNTING_HOLE_DIAMETER / 2.0
    half_extent = hole_radius + const.PANEL_MOUNTING_SLOT_EXTRA  # cm

    # Vertical position of the slot/hole centre measured from each edge
    y_from_edge = const.PANEL_MIN_EDGE_CLEARANCE + hole_radius
    y_bottom = y_from_edge
    y_top    = panel_height - y_from_edge

    # If the panel is too short, collapse both rows to the vertical centre
    if y_top <= y_bottom:
        y_bottom = panel_height / 2.0
        y_top    = None

    x_positions = _mounting_x_positions(panel_width, half_extent)
    circles = sketch.sketchCurves.sketchCircles

    for x in x_positions:
        if style == 'oblong':
            _draw_oblong_slot(sketch, x, y_bottom, half_extent, hole_radius)
            if y_top is not None:
                _draw_oblong_slot(sketch, x, y_top, half_extent, hole_radius)
        else:
            circles.addByCenterRadius(
                adsk.core.Point3D.create(x, y_bottom, 0), hole_radius)
            if y_top is not None:
                circles.addByCenterRadius(
                    adsk.core.Point3D.create(x, y_top, 0), hole_radius)


def _mounting_x_positions(panel_width, half_extent):
    """Return a list of X centre positions (cm) for mounting features.

    The leftmost and rightmost holes are always at the same fixed offset
    from their respective edges (edge_clearance + slot half-length),
    regardless of panel width.  Interior holes are added at
    PANEL_MOUNTING_HOLE_SPACING intervals stepping inward from the left
    anchor, provided they stay at least half a pitch away from the right
    anchor (so holes never crowd together).
    """
    spacing    = const.PANEL_MOUNTING_HOLE_SPACING
    edge_offset = const.PANEL_MIN_EDGE_CLEARANCE + half_extent

    left_x  = edge_offset
    right_x = panel_width - edge_offset

    if right_x <= left_x:
        return [panel_width / 2.0]

    positions = [left_x]

    # Walk right from the left anchor; stop before we crowd the right anchor
    x = left_x + spacing
    while x < right_x - spacing / 2.0:
        positions.append(x)
        x += spacing

    if abs(right_x - positions[-1]) > 0.01:   # avoid duplicate when they coincide
        positions.append(right_x)

    return positions


def _draw_oblong_slot(sketch, cx, cy, half_extent, radius):
    """Draw a pill-shaped (oblong) slot centred at (cx, cy).

    Args:
        half_extent: Half the total slot length (= radius + extra overhang).
        radius:      Radius of the semicircular end caps (hole radius).
    """
    track_half = half_extent - radius  # half the centre-to-centre arc distance

    if track_half <= 0:
        # Degenerate — just a circle
        sketch.sketchCurves.sketchCircles.addByCenterRadius(
            adsk.core.Point3D.create(cx, cy, 0), radius)
        return

    arcs  = sketch.sketchCurves.sketchArcs
    lines = sketch.sketchCurves.sketchLines

    lx = cx - track_half
    rx = cx + track_half

    # Left cap: start at bottom, sweep CW 180° → passes through left (-X) side
    arcs.addByCenterStartSweep(
        adsk.core.Point3D.create(lx, cy, 0),
        adsk.core.Point3D.create(lx, cy - radius, 0),
        -math.pi,
    )
    # Right cap: start at top, sweep CW 180° → passes through right (+X) side
    arcs.addByCenterStartSweep(
        adsk.core.Point3D.create(rx, cy, 0),
        adsk.core.Point3D.create(rx, cy + radius, 0),
        -math.pi,
    )
    # Top edge
    lines.addByTwoPoints(
        adsk.core.Point3D.create(lx, cy + radius, 0),
        adsk.core.Point3D.create(rx, cy + radius, 0),
    )
    # Bottom edge
    lines.addByTwoPoints(
        adsk.core.Point3D.create(rx, cy - radius, 0),
        adsk.core.Point3D.create(lx, cy - radius, 0),
    )
