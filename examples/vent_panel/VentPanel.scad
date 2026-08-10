// VentPanel
// MakerPanel-compatible ventilation panel with selectable vent patterns.

include <common.scad>
include <makerpanel/panel.scad>
use <IsoGridScad/isogrid.scad>

/* [Customization] */
panelThickness = 3; // [1:0.5:6] Panel thickness in millimeters
horizontalPitch = 35; // [4:1:80] MakerPanel width in HP
verticalUnits = 5; // [1:1:8] MakerPanel height in U
inset = 10; // [2:1:30] Solid border around the vents in millimeters
type = "Holes"; // [Holes, Honeycomb, Isogrid]
gridScale = 1; // [0.5:0.05:1.2] Vent opening scale
fan = "None"; // [None, 40mm, 60mm, 80mm, 92mm, 120mm]

/* [Part Selection] */
part = "panel"; // [panel, panel_2d]

/* [Hidden] */
holeSpacing = 12;
isogridTriangleSize = 15;
isogridBaseHoleSize = 5;
basePassthrough = 0.5;
fanMountHoleDiameter = 5;
fanMountPadDiameter = 8;
epsilon = 0.01;

function panel_width() = hp_to_mm(horizontalPitch);
function panel_height() = u_to_mm(verticalUnits);
function vent_width() = panel_width() - 2 * inset;
function vent_height() = panel_height() - 2 * inset;
function target_passthrough() =
    min(0.72, basePassthrough * pow(gridScale, 2));
function round_hole_diameter() =
    2 * holeSpacing * sqrt(target_passthrough() / PI);
function honeycomb_center_spacing() = holeSpacing;
function honeycomb_diameter() =
    2 * honeycomb_center_spacing()
        * sqrt(target_passthrough() / 3);
function honeycomb_wall() =
    honeycomb_center_spacing()
        * (1 - sqrt(target_passthrough()));
function isogrid_hole_size() = isogridBaseHoleSize * gridScale;
function iso_primitive(value, radius, side) =
    value * sqrt(max(0, radius * radius - value * value))
    + radius * radius * asin(value / radius) * PI / 180
    - side * value;
function iso_corner_area(thickness, radius) =
    let(
        value = (
            sqrt(4 * radius * radius - thickness * thickness)
            - sqrt(3) * thickness
        ) / 4
    )
    value * sqrt(max(0, radius * radius - value * value))
    + radius * radius * asin(value / radius) * PI / 180
    - 2 * thickness * value
    - sqrt(3) * value * value;
function iso_pair_overlap(thickness, radius, side) =
    let(
        lower = thickness / 2,
        upper = sqrt(max(
            0,
            radius * radius - side * side / 4
        ))
    )
    upper <= lower
        ? 0
        : iso_primitive(upper, radius, side)
            - iso_primitive(lower, radius, side);
function iso_open_ratio(thickness) =
    let(
        side = isogridTriangleSize,
        holeRadius = isogrid_hole_size() / 2,
        radius = holeRadius + thickness,
        cellArea = side * side * sqrt(3) / 2,
        openingSide = side - sqrt(3) * thickness,
        triangleArea = sqrt(3) * openingSide * openingSide / 2,
        reinforcedArea = 6 * iso_corner_area(thickness, radius),
        overlapArea = 6 * iso_pair_overlap(
            thickness,
            radius,
            side
        ),
        holeArea = PI * holeRadius * holeRadius
    )
    (
        triangleArea - reinforcedArea + overlapArea + holeArea
    ) / cellArea;
function iso_bisect(low, high, iterations) =
    iterations <= 0
        ? (low + high) / 2
        : let(
            middle = (low + high) / 2,
            ratio = iso_open_ratio(middle)
        )
        ratio > target_passthrough()
            ? iso_bisect(middle, high, iterations - 1)
            : iso_bisect(low, middle, iterations - 1);
function isogrid_thickness() =
    let(
        holeRadius = isogrid_hole_size() / 2,
        upper = isogridTriangleSize / sqrt(3) - holeRadius
    )
    iso_bisect(0, upper, 32);
function fan_size(selection) =
    selection == "40mm" ? 40 :
    selection == "60mm" ? 60 :
    selection == "80mm" ? 80 :
    selection == "92mm" ? 92 :
    selection == "120mm" ? 120 : 0;
function fan_mount_spacing(size) =
    size == 40 ? 32 :
    size == 60 ? 50 :
    size == 80 ? 71.5 :
    size == 92 ? 82.5 :
    size == 120 ? 105 : 0;
function fan_fits(size) =
    let(
        spacing = fan_mount_spacing(size),
        panelHoleX = panel_width() / 2 - RACK_RAIL_HEIGHT / 2,
        panelHoleY = panel_height() / 2 - RACK_RAIL_HEIGHT / 2,
        holeSeparation = sqrt(
            pow(panelHoleX - spacing / 2, 2)
            + pow(panelHoleY - spacing / 2, 2)
        ),
        minimumSeparation =
            (MOUNT_HOLE_DIAMETER + fanMountPadDiameter) / 2
    )
    size <= panel_width()
        && size <= panel_height()
        && holeSeparation >= minimumSeparation;
function effective_fan_size() =
    let(requested = fan_size(fan))
    requested >= 120 && fan_fits(120) ? 120 :
    requested >= 92 && fan_fits(92) ? 92 :
    requested >= 80 && fan_fits(80) ? 80 :
    requested >= 60 && fan_fits(60) ? 60 :
    requested >= 40 && fan_fits(40) ? 40 : 0;

module vent_bounds() {
    square([vent_width(), vent_height()], center=true);
}

module fan_mount_holes() {
    spacing = fan_mount_spacing(effective_fan_size());

    if (spacing > 0) {
        for (x = [-spacing / 2, spacing / 2]) {
            for (y = [-spacing / 2, spacing / 2]) {
                translate([x, y])
                    circle(d=fanMountHoleDiameter, $fn=32);
            }
        }
    }
}

module fan_mount_pads() {
    spacing = fan_mount_spacing(effective_fan_size());

    if (spacing > 0) {
        for (x = [-spacing / 2, spacing / 2]) {
            for (y = [-spacing / 2, spacing / 2]) {
                translate([x, y])
                    circle(d=fanMountPadDiameter, $fn=32);
            }
        }
    }
}

module perforation_pattern() {
    intersection() {
        vent_bounds();
        if (type == "Honeycomb") {
            honeycomb_hole_pattern();
        } else {
            round_hole_pattern();
        }
    }
}

module round_hole_pattern() {
    columns = max(
        1,
        ceil(vent_width() / holeSpacing) + 2
    );
    rows = max(
        1,
        ceil(vent_height() / holeSpacing) + 2
    );

    for (column = [0:1:columns - 1]) {
        for (row = [0:1:rows - 1]) {
            x = (column - (columns - 1) / 2) * holeSpacing;
            y = (row - (rows - 1) / 2) * holeSpacing;
            translate([x, y])
                circle(d=round_hole_diameter(), $fn=32);
        }
    }
}

module honeycomb_hole_pattern() {
    cellRadius = honeycomb_diameter() / 2
        + honeycomb_wall() / sqrt(3);
    horizontalSpacing = 3 * cellRadius / 2;
    verticalSpacing = sqrt(3) * cellRadius;
    columns = max(
        1,
        ceil(vent_width() / horizontalSpacing) + 2
    );
    rows = max(
        1,
        ceil(vent_height() / verticalSpacing) + 2
    );

    intersection() {
        vent_bounds();
        for (column = [0:1:columns - 1]) {
            for (row = [0:1:rows - 1]) {
                yOffset = (column % 2) * verticalSpacing / 2;
                x = (column - (columns - 1) / 2)
                    * horizontalSpacing;
                y = (row - (rows - 1) / 2) * verticalSpacing
                    + yOffset;
                translate([x, y])
                    circle(d=honeycomb_diameter(), $fn=6);
            }
        }
    }
}

module perforated_panel_2d() {
    difference() {
        union() {
            makerpanel_2d(horizontalPitch, verticalUnits);
            fan_mount_pads();
        }
        union() {
            difference() {
                perforation_pattern();
                fan_mount_pads();
            }
            fan_mount_holes();
        }
    }
}

module isogrid_panel_2d() {
    difference() {
        union() {
            intersection() {
                makerpanel_2d(horizontalPitch, verticalUnits);
                union() {
                    difference() {
                        square([panel_width(), panel_height()], center=true);
                        vent_bounds();
                    }
                    isogrid_rect(
                        vent_width(),
                        vent_height(),
                        triangle_size=isogridTriangleSize,
                        thickness=isogrid_thickness(),
                        extrude=0,
                        hole_size=isogrid_hole_size()
                    );
                }
            }
            fan_mount_pads();
        }
        fan_mount_holes();
    }
}

module vent_panel_2d() {
    assert(
        vent_width() > 0 && vent_height() > 0,
        "Inset must leave a positive ventilation area."
    );
    assert(
        type == "Holes" || type == "Honeycomb" || type == "Isogrid",
        "Type must be Holes, Honeycomb, or Isogrid."
    );
    assert(
        gridScale >= 0.5 && gridScale <= 1.2,
        "Grid scale must be between 0.5 and 1.2."
    );
    assert(
        fan == "None" || fan_size(fan) > 0,
        "Fan must be None, 40mm, 60mm, 80mm, 92mm, or 120mm."
    );

    if (fan != "None" && effective_fan_size() != fan_size(fan)) {
        echo(
            str(
                "Requested ", fan, " fan does not fit; using ",
                effective_fan_size() > 0
                    ? str(effective_fan_size(), "mm")
                    : "None",
                "."
            )
        );
    }

    if (type == "Isogrid") {
        isogrid_panel_2d();
    } else {
        perforated_panel_2d();
    }
}

module vent_panel(thickness=panelThickness) {
    linear_extrude(height=thickness)
        vent_panel_2d();
}

if (part == "panel_2d") {
    vent_panel_2d();
} else {
    vent_panel();
}
