# All dimensions are in centimetres — Fusion 360's internal length unit.
# 1 cm = 10 mm.  Convert to mm with * 10, to inches with / 2.54.

# ---------------------------------------------------------------------------
# Horizontal Pitch (HP) — base width unit for MakerPanels
# ---------------------------------------------------------------------------
HP_UNIT = 0.508     # 5.08 mm per HP

# ---------------------------------------------------------------------------
# Height unit (U)
# ---------------------------------------------------------------------------
U_UNIT = 4.445      # 44.45 mm = 1U

# ---------------------------------------------------------------------------
# Standard panel heights
# ---------------------------------------------------------------------------
PANEL_1U_HEIGHT   = 4.445     # 44.45 mm — compact 1U panel
PANEL_1_5U_HEIGHT = 6.6675   # 66.675 mm — 1.5U panel
PANEL_2U_HEIGHT   = 8.89      # 88.9 mm — 2U panel
PANEL_2_5U_HEIGHT = 11.1125  # 111.125 mm — 2.5U panel
PANEL_3U_HEIGHT   = 12.85     # 128.5 mm — standard 3U panel height
PANEL_3_5U_HEIGHT = 15.5575  # 155.575 mm — 3.5U panel
PANEL_4U_HEIGHT   = 17.78     # 177.8 mm — 4U panel
PANEL_4_5U_HEIGHT = 20.0025  # 200.025 mm — 4.5U panel
PANEL_5U_HEIGHT   = 22.225   # 222.25 mm — 5U panel

# Rail mounting-centre spacing
RAIL_3U_SPACING = 13.335    # 133.35 mm — 3U rail mounting centres (3 × 1U)

# ---------------------------------------------------------------------------
# Panel mounting hardware
# ---------------------------------------------------------------------------
# Slots are spaced at 25 mm centres along the top and bottom panel edges.
PANEL_MOUNTING_HOLE_SPACING = 2.5   # 25.0 mm centre-to-centre
# M3 clearance hole (3.2 mm diameter)
PANEL_MOUNTING_HOLE_DIAMETER = 0.32
# Extra half-length added to each side of a circular hole to form an
# oblong (adjustment) slot.  Total slot length = diameter + 2 × extra.
PANEL_MOUNTING_SLOT_EXTRA = 0.25    # 2.5 mm

# Minimum clearance from any panel edge to the nearest feature
PANEL_MIN_EDGE_CLEARANCE = 0.2      # 2.0 mm

# ---------------------------------------------------------------------------
# Rail slot profile — values match common.scad
# ---------------------------------------------------------------------------
RAIL_SLOT_HEIGHT = 0.69         # 6.9 mm  — T-slot nut width (M5/M6)
RAIL_SLOT_MIN_WIDTH = 5.75 * HP_UNIT  # 29.21 mm — minimum slot width (5.75 HP)
RAIL_SUPPORT_WIDTH = 0.3        # 3.0 mm  — structural web between slots
RAIL_SLOT_CORNER_RADIUS = 0.1   # 1.0 mm  — rounded slot corners

# Default rail strip height when not specified by the user
RAIL_DEFAULT_HEIGHT = 1.1   # 11.0 mm

# Rail end-hole clearance diameters (cm) — standard metric clearance fits
RAIL_HOLE_DIAMETER_M3 = 0.35   # 3.5 mm  — matches RACK_HOLE_DIAMETER in common.scad
RAIL_HOLE_DIAMETER_M4 = 0.43   # 4.3 mm
RAIL_HOLE_DIAMETER_M5 = 0.53   # 5.3 mm
RAIL_HOLE_DIAMETER_M6 = 0.64   # 6.4 mm
