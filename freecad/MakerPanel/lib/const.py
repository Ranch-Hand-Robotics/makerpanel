"""MakerPanel specification constants for the FreeCAD workbench.

All dimensions are in millimetres — FreeCAD's native length unit.
"""

from __future__ import annotations

# ---------------------------------------------------------------------------
# Horizontal Pitch (HP) — base width unit for MakerPanels
# ---------------------------------------------------------------------------
HP_UNIT = 5.08  # 5.08 mm per HP

# ---------------------------------------------------------------------------
# Height unit (U)
# ---------------------------------------------------------------------------
U_UNIT = 44.45  # 44.45 mm = 1U

# ---------------------------------------------------------------------------
# Standard panel heights
# ---------------------------------------------------------------------------
PANEL_1U_HEIGHT = 44.45
PANEL_1_5U_HEIGHT = 66.675
PANEL_2U_HEIGHT = 88.9
PANEL_2_5U_HEIGHT = 111.125
PANEL_3U_HEIGHT = 128.5
PANEL_3_5U_HEIGHT = 155.575
PANEL_4U_HEIGHT = 177.8
PANEL_4_5U_HEIGHT = 200.025
PANEL_5U_HEIGHT = 222.25

PANEL_HEIGHT_PRESETS = (
    ("1U", PANEL_1U_HEIGHT),
    ("1.5U", PANEL_1_5U_HEIGHT),
    ("2U", PANEL_2U_HEIGHT),
    ("2.5U", PANEL_2_5U_HEIGHT),
    ("3U", PANEL_3U_HEIGHT),
    ("3.5U", PANEL_3_5U_HEIGHT),
    ("4U", PANEL_4U_HEIGHT),
    ("4.5U", PANEL_4_5U_HEIGHT),
    ("5U", PANEL_5U_HEIGHT),
)

# Rail mounting-centre spacing
RAIL_3U_SPACING = 133.35

# ---------------------------------------------------------------------------
# Panel mounting hardware
# ---------------------------------------------------------------------------
PANEL_MOUNTING_HOLE_SPACING = 25.0
PANEL_MOUNTING_HOLE_DIAMETER = 3.2
PANEL_MOUNTING_SLOT_EXTRA = 2.5
PANEL_MIN_EDGE_CLEARANCE = 2.0

# ---------------------------------------------------------------------------
# Rail slot profile
# ---------------------------------------------------------------------------
RAIL_SLOT_HEIGHT = 6.9
RAIL_SLOT_MIN_WIDTH = 5.75 * HP_UNIT
RAIL_SUPPORT_WIDTH = 3.0
RAIL_SLOT_CORNER_RADIUS = 1.0

# Default rail strip height when not specified by the user
RAIL_DEFAULT_HEIGHT = 11.0

# Rail end-hole clearance diameters
RAIL_HOLE_DIAMETER_M3 = 3.5
RAIL_HOLE_DIAMETER_M4 = 4.3
RAIL_HOLE_DIAMETER_M5 = 5.3
RAIL_HOLE_DIAMETER_M6 = 6.4
