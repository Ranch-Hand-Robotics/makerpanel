// PowerPanel
// Adapted from rear-interface connector geometry; source credited in README.md.
// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// See README.md for attribution, changes, and fabrication notes.

include <makerpanel/common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
horizontalPitch = 20; // [4:1:80] MakerPanel width in HP
verticalUnits = 1; // [1:1:8] MakerPanel height in U
type = "Neutrik powerCON"; // [Neutrik powerCON, AC Computer Power cable, Anderson Powerpole]
panelThickness = 3; // [1:0.5:6] Panel thickness in millimeters

/* [Connector Mounting] */
// Added to body and mounting-hole diameters or IEC opening dimensions.
connectorClearance = 0.4; // [0:0.1:1.5]
connectorMountHoleDiameter = 3.2; // [2.5:0.1:4]

/* [Neutrik powerCON] */
powerconBodyDiameter = 24; // [22:0.1:26]
powerconPairSpacing = 42; // [35:0.5:60]
powerconMountSpacingX = 24; // [18:0.5:28]
// Rear-panel Z spacing becomes Y spacing on the flat MakerPanel.
powerconMountSpacingY = 19; // [15:0.5:25]

/* [IEC C14] */
iecC14CutoutWidth = 27.5; // [25:0.1:32]
iecC14CutoutHeight = 20; // [18:0.1:24]
iecC14MountSpacing = 40; // [35:0.5:50]

/* [Anderson Powerpole] */
powerpolePairWidth = 16; // [15:0.05:17]
powerpolePairHeight = 8; // [7.5:0.05:9]
// Per-side clearance; independent of connectorClearance.
powerpoleFitClearance = 0.15; // [0:0.05:0.5]
powerpoleKeyDepth = 1.2; // [0.5:0.1:2]
powerpoleKeyHeight = 3; // [1.5:0.1:5]
powerpoleKeyTaper = 0.5; // [0:0.1:1]

/* [Part Selection] */
part = "makerpanel"; // [makerpanel, panel_2d]

/* [Hidden] */
epsilon = 0.01;

module power_panel_rounded_rect_2d(w, h, r) {
    rr = min(max(0, r), min(w, h) / 2);
    if (rr > epsilon) {
        hull() {
            for (sx = [-1, 1]) {
                for (sy = [-1, 1]) {
                    translate([
                        sx * max(epsilon, w/2 - rr),
                        sy * max(epsilon, h/2 - rr)
                    ])
                        circle(r=rr, $fn=24);
                }
            }
        }
    } else {
        square([w, h], center=true);
    }
}

module power_panel_powercon_cutouts_2d() {
    body_d = powerconBodyDiameter + connectorClearance;
    mount_d = connectorMountHoleDiameter + connectorClearance;

    for (connector_x = [-powerconPairSpacing/2, powerconPairSpacing/2]) {
        translate([connector_x, 0])
            circle(d=body_d, $fn=48);

        // Common Neutrik D-series diagonal two-hole flange pattern.
        for (sign = [-1, 1]) {
            translate([
                connector_x - sign * powerconMountSpacingX/2,
                sign * powerconMountSpacingY/2
            ])
                circle(d=mount_d, $fn=24);
        }
    }
}

module power_panel_iec_c14_cutouts_2d() {
    cut_w = iecC14CutoutWidth + connectorClearance;
    cut_h = iecC14CutoutHeight + connectorClearance;

    power_panel_rounded_rect_2d(cut_w, cut_h, 1.5);
    for (sign = [-1, 1]) {
        translate([sign * iecC14MountSpacing/2, 0])
            circle(
                d=connectorMountHoleDiameter + connectorClearance,
                $fn=24
            );
    }
}

module power_panel_powerpole_cutouts_2d() {
    clearance = max(0, powerpoleFitClearance);
    body_w = powerpolePairWidth + 2*clearance;
    body_h = powerpolePairHeight + 2*clearance;
    key_depth = max(0, powerpoleKeyDepth);
    key_half_h = min(body_h/2, powerpoleKeyHeight/2 + clearance);
    key_taper = min(max(0, powerpoleKeyTaper), key_half_h);

    // Preserve the bonded pair's keyed +X side and adhesive-fit perimeter.
    polygon([
        [-body_w/2, -body_h/2],
        [ body_w/2, -body_h/2],
        [ body_w/2, -key_half_h],
        [ body_w/2 + key_depth, -key_half_h + key_taper],
        [ body_w/2 + key_depth,  key_half_h - key_taper],
        [ body_w/2,  key_half_h],
        [ body_w/2,  body_h/2],
        [-body_w/2,  body_h/2]
    ]);
}

module power_panel_cutouts_2d() {
    if (type == "Neutrik powerCON") {
        power_panel_powercon_cutouts_2d();
    } else if (type == "AC Computer Power cable") {
        power_panel_iec_c14_cutouts_2d();
    } else if (type == "Anderson Powerpole") {
        power_panel_powerpole_cutouts_2d();
    }
}

module power_panel_2d() {
    difference() {
        makerpanel_2d(horizontalPitch, verticalUnits);
        power_panel_cutouts_2d();
    }
}

module power_panel(thickness=panelThickness) {
    panel_extrude([hp_to_mm(horizontalPitch), u_to_mm(verticalUnits)],
        thickness, chamfer_start=1.2)
        power_panel_2d();
}

if (part == "panel_2d") {
    power_panel_2d();
} else if (part == "makerpanel") {
    power_panel();
}