"""
panelGenerator.py — MakerPanel 2D sketch generator.

Creates a parametric Fusion 360 sketch of a MakerPanel outline on the XY
plane of the supplied component.  All coordinates are in centimetres (Fusion
360 internal length unit).

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
    minimalMounting: bool = False,
    existing_sketch: adsk.fusion.Sketch = None,
) -> adsk.fusion.Sketch:
    """Create a 2D MakerPanel sketch on the component's XY plane.

    Args:
        component:        Target Fusion 360 component.
        widthHp:          Panel width in HP units (1 HP = 5.08 mm).
        heightMm:         Panel height in mm.
        addMountingSlots: When True, T-slot mounting features are added.
        slotStyle:        'oblong' → elongated adjustment slots (default);
                          'circle' → standard circular clearance holes.
        minimalMounting:  When True, only left edge, right edge, and centre
                          mounting features are placed instead of a full row
                          at every 25 mm interval.
        existing_sketch:  When provided, geometry is drawn into this sketch
                          instead of creating a new one (e.g. when the user
                          invokes the command while editing a sketch).

    Returns:
        The adsk.fusion.Sketch object containing the panel geometry.
    """
    panel_width  = widthHp * const.HP_UNIT  # cm
    panel_height = heightMm / 10.0           # mm → cm

    # Centre the panel at the world origin
    ox = -panel_width  / 2.0
    oy = -panel_height / 2.0

    if existing_sketch is not None:
        sketch = existing_sketch
    else:
        sketch = component.sketches.add(component.xYConstructionPlane)
        sketch.name = f'MakerPanel {widthHp}HP x {heightMm:.1f}mm'

    # Outer panel boundary
    sketch.sketchCurves.sketchLines.addTwoPointRectangle(
        adsk.core.Point3D.create(ox,                  oy,                   0),
        adsk.core.Point3D.create(ox + panel_width,    oy + panel_height,    0),
    )

    if addMountingSlots:
        _add_mounting_features(sketch, panel_width, panel_height, slotStyle, ox, oy,
                               minimal=minimalMounting)

    return sketch


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

def _add_mounting_features(sketch, panel_width, panel_height, style, ox, oy, minimal=False):
    """Add mounting holes or oblong slots at the top and bottom of the panel."""
    hole_radius = const.PANEL_MOUNTING_HOLE_DIAMETER / 2.0
    half_extent = hole_radius + const.PANEL_MOUNTING_SLOT_EXTRA  # cm

    # Vertical position of the slot/hole centre measured from each edge
    y_from_edge = const.PANEL_MIN_EDGE_CLEARANCE + hole_radius
    y_bottom = oy + y_from_edge
    y_top    = oy + panel_height - y_from_edge

    # If the panel is too short, collapse both rows to the vertical centre
    if y_top <= y_bottom:
        y_bottom = oy + panel_height / 2.0
        y_top    = None

    if minimal:
        x_positions = _mounting_x_positions_minimal(panel_width, half_extent, ox)
    else:
        x_positions = _mounting_x_positions(panel_width, half_extent, ox)
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


def _mounting_x_positions_minimal(panel_width, half_extent, ox):
    """Return X positions for minimal mounting: left edge, centre, right edge.

    If the panel is narrow enough that left and right coincide, only the
    centre is returned.  If the centre coincides with an edge position it is
    deduplicated so no two features land on the same spot.
    """
    edge_offset = const.PANEL_MIN_EDGE_CLEARANCE + half_extent
    left_x  = ox + edge_offset
    right_x = ox + panel_width - edge_offset
    mid_x   = ox + panel_width / 2.0

    if right_x <= left_x:
        return [mid_x]

    positions = [left_x]
    # Only add centre if it doesn't overlap an edge position (> 1 mm gap)
    if abs(mid_x - left_x) > 0.1 and abs(mid_x - right_x) > 0.1:
        positions.append(mid_x)
    positions.append(right_x)
    return positions


def _mounting_x_positions(panel_width, half_extent, ox):
    """Return a list of X centre positions (cm) for mounting features.

    Corner holes are placed at a fixed offset from each edge.  Any
    interior holes are distributed evenly in the span between the two
    corner holes, with the number of gaps chosen to be the closest whole
    number to (span / PANEL_MOUNTING_HOLE_SPACING).
    """
    edge_offset = const.PANEL_MIN_EDGE_CLEARANCE + half_extent

    left_x  = ox + edge_offset
    right_x = ox + panel_width - edge_offset

    if right_x <= left_x:
        return [ox + panel_width / 2.0]

    span    = right_x - left_x
    n_gaps  = max(1, round(span / const.PANEL_MOUNTING_HOLE_SPACING))

    return [left_x + i * span / n_gaps for i in range(n_gaps + 1)]


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
