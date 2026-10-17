// Grid Plate MakerPanel: perforated carrier with optional SBC standoffs.
// SPDX-License-Identifier: MIT
// Board patterns are shared with MakerStack; verify your board revision.

include <makerpanel/common.scad>
use <makerpanel/panel.scad>
use <makerpanel/makerstack.scad>

/* [Panel] */
horizontalPitch = 35; // [4:1:80]
verticalUnits = 3; // [0.5:0.5:8]
panelThickness = 3; // [1:0.5:6]

/* [Mounting Grid] */
gridPitch = 12.7; // [6.35:0.25in, 12.7:0.5in, 25.4:1in, 10:10mm, 20:20mm, 25:25mm]
gridHoleDiameter = 3.4; // [1:0.1:5]
// Minimum hole-center distance from the outside edge.
gridMargin = 6; // [3:0.5:15]

/* [SBC Mounting] */
sbc = "none"; // [none:None, nano:Jetson Nano, pi:Raspberry Pi, latte:LattePanda, all:All patterns]
standoffHeight = 6; // [3:1:15]
standoffDiameter = 7; // [5:0.5:10]
// Printed pilot diameter = board screw diameter minus relief.
standoffRelief = 0.4; // [0:0.1:1]

/* [Part Selection] */
part = "makerpanel"; // [makerpanel, panel_2d]

/* [Hidden] */
$fn = 48;
panelSize = [hp_to_mm(horizontalPitch), u_to_mm(verticalUnits)];
edgeInset = max(0, panelThickness - 1.2);
mountWeb = 2;

// Match the canonical panel's corner holes (or side pair below 1U).
function grid_plate_mount_points(hp, u) =
    [for (sx = [-1, 1], sy = u < 1 ? [0] : [-1, 1])
        [sx * (hp_to_mm(hp) - RACK_RAIL_HEIGHT) / 2,
            sy * (u_to_mm(u) - RACK_RAIL_HEIGHT) / 2]];

function grid_plate_point_fits(p, size, radius, edge) =
    abs(p[0]) + radius + edge <= size[0] / 2
        && abs(p[1]) + radius + edge <= size[1] / 2;

// Reject a whole pattern, never leave a board with missing mounting posts.
function grid_plate_sbc_fits(spec, size, mounts, diameter, edge) =
    spec[2] <= size[0] && spec[3] <= size[1]
        && len([for (p = makerstack_sbc_mount_2d(spec))
            if (!grid_plate_point_fits(p, size, diameter / 2, edge)
                || !makerstack_grid_clear(p, mounts,
                    (diameter + MOUNT_HOLE_DIAMETER) / 2 + mountWeb))
                p]) == 0;

mountPoints = grid_plate_mount_points(horizontalPitch, verticalUnits);
boardSpecs = [for (spec = makerstack_sbc_selected(sbc))
    if (grid_plate_sbc_fits(spec, panelSize, mountPoints,
        standoffDiameter, edgeInset + 1)) spec];
boardPoints = [for (spec = boardSpecs)
    for (p = makerstack_sbc_mount_2d(spec)) p];
gridPoints = [for (p = makerstack_grid_points(panelSize, gridPitch,
    max(gridMargin, gridHoleDiameter / 2 + edgeInset + 1),
    boardPoints, (standoffDiameter + gridHoleDiameter) / 2 + 1))
    if (makerstack_grid_clear(p, mountPoints,
        (gridHoleDiameter + MOUNT_HOLE_DIAMETER) / 2 + mountWeb)) p];

// Printed posts have blind bores above the plate. The flat 2D alternative
// replaces them with board-screw through holes for separate metal spacers.
module grid_plate_2d(sbc_holes = true) {
    difference() {
        makerpanel_2d(horizontalPitch, verticalUnits);
        for (p = gridPoints)
            translate(p) circle(d = gridHoleDiameter);
        if (sbc_holes)
            for (spec = boardSpecs)
                for (p = makerstack_sbc_mount_2d(spec))
                    translate(p) circle(d = spec[5]);
    }
}

module grid_plate() {
    union() {
        panel_extrude(panelSize, panelThickness, chamfer_start = 1.2)
            grid_plate_2d(sbc_holes = false);
        translate([0, 0, panelThickness])
            for (spec = boardSpecs)
                makerstack_sbc_standoffs(spec[0], standoffHeight,
                    standoffDiameter, standoffRelief);
    }
}

for (spec = makerstack_sbc_selected(sbc))
    if (!grid_plate_sbc_fits(spec, panelSize, mountPoints,
        standoffDiameter, edgeInset + 1))
        echo(str(spec[1], " pattern omitted: increase panel size or reduce",
            " standoff diameter; check rail-mount clearance."));

if (part == "makerpanel") {
    grid_plate();
} else if (part == "panel_2d") {
    grid_plate_2d();
}