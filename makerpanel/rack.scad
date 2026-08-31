// Maker Panel Adapter for Standard Racks
// This module defines the rack panels for standard 19" and 10" racks, with support for T-slot mounting 
// and customizable hole patterns. The panels are designed to fit within the MakerPanel system, allowing 
// for modular integration of components while maintaining compatibility with standard rack equipment. The rack panels can be customized 
// in width (19" or 10"), height (in U), and hole patterns to accommodate various mounting needs.

include <common.scad>
include <rails.scad>

part = "rack_19"; // [rack_19, rack_10, rack_19_2d, rack_10_2d]

rack_height_u = 2; // Height of the rack in Standard Rack Units

function rack_outer_width_mm(rack_width_inches) = rack_width_inches * INCH;
function rack_mount_c2c_mm(rack_width_inches) =
    (rack_width_inches == 19 ? 18.312 : 9.312) * INCH;
function rack_center_clearance_mm(rack_width_inches) =
    rack_width_inches == 19 ? 450 : 220;

RACK_19_OUTER_WIDTH = rack_outer_width_mm(19);  // 19 inches = 482.6 mm
RACK_19_MOUNT_C2C = rack_mount_c2c_mm(19);      // 18.312 inches = 465.1248 mm
RACK_19_CENTER_CLEARANCE = rack_center_clearance_mm(19);

RACK_10_OUTER_WIDTH = rack_outer_width_mm(10);  // 10 inches = 254 mm
RACK_10_MOUNT_C2C = rack_mount_c2c_mm(10);      // 9.312 inches = 236.5248 mm
RACK_10_CENTER_CLEARANCE = rack_center_clearance_mm(10);
RACK_HOLE_EDGE_OFFSET = 6.35;
RACK_MOUNT_HOLE_DIAMETER = 6.5;

// Rack dimensions are stored in millimeters after explicit inch conversion.


// EIA vertical pattern: 15.875 mm, 15.875 mm, then 12.7 mm to the next U.
//     O
//     15.875mm
//     O
//     15.875mm
//     O
//     12.7mm (to next U)
//     O
//     15.875mm
//     O
//     15.875mm
//     O

// Holes in the sides of the rack adapter, should be oval to allow for some horizontal adjustment when mounting to the rack rails.
// Hole pattern is designed to be compatible with standard rack mounting rails, which typically have mounting holes

// Example pattern for 1U rack adapter, exaggerated for clarity:
//┌───────────────────────────────────────────────────────────────────┐
//│      ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │
//│  O   │               │  │               │  │               │  O   │
//│      └───────────────┘  └───────────────┘  └───────────────┘      │
//│      ┌─────────────────────────────────────────────────────┐      │
//│      │                                                     │      │
//│      │                                                     │      │
//│      │                                                     │      │
//│  O   │                                                     │  O   │
//│      │                                                     │      │      
//│      │                                                     │      │
//│      │                                                     │      │
//│      └─────────────────────────────────────────────────────┘      │
//│      ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │
//│  O   │               │  │               │  │               │  O   │
//│      └───────────────┘  └───────────────┘  └───────────────┘      │
//└───────────────────────────────────────────────────────────────────┘


// ============================================
// Helper: Horizontal slot / obround hole
// ============================================

module obround_slot_2d(length, diameter) {
    l = max(length, diameter);
    hull() {
        translate([-(l - diameter)/2, 0])
            circle(d=diameter, $fn=32);
        translate([(l - diameter)/2, 0])
            circle(d=diameter, $fn=32);
    }
}

// ============================================
// Helper: Standard rack mounting holes for N-U panel
// ============================================

module rack_mount_hole_pair_2d(y, hole_c2c, slot_len=8, hole_d=6.5) {
    // Left ear
    translate([-hole_c2c/2, y])
        obround_slot_2d(slot_len, hole_d);

    // Right ear
    translate([hole_c2c/2, y])
        obround_slot_2d(slot_len, hole_d);
}

module rack_mount_holes_2d(rack_u, hole_c2c, slot_len=8, hole_d=6.5) {
    height = u_to_mm(rack_u);
    y_min = -height/2;

    // Per-U EIA vertical hole positions (from each U start)
    hole_offsets = [RACK_HOLE_EDGE_OFFSET, U/2, U - RACK_HOLE_EDGE_OFFSET];

    for (u_idx = [0 : rack_u - 1]) {
        for (offset = hole_offsets) {
            y = y_min + u_idx * U + offset;
            rack_mount_hole_pair_2d(y, hole_c2c, slot_len, hole_d);
        }
    }
}

// ============================================
// Helper: Generic rack faceplate (2D)
// ============================================

module rack_faceplate_2d(
    rack_u,
    outer_width,
    hole_c2c,
    center_clearance,
    rack_mounting_holes=true,
    rail_edge_margin=RACK_SUPPORT_WIDTH
) {
    height = u_to_mm(rack_u);
    rail_row_center_offset = height/2 - RACK_RAIL_HEIGHT/2; // align to MakerPanel hole centerlines (half rail-height inset from each edge)

    // Expand center opening as much as safely possible.
    // Width limit: keep margin from inner edge of rack mounting slots.
    max_center_width_from_holes = rack_mounting_holes
        ? hole_c2c - RACK_MOUNT_SLOT_LEN
            - 2 * CENTER_CUTOUT_SIDE_MARGIN
        : outer_width - 2 * RACK_SUPPORT_WIDTH;
    center_open_width = min(
        outer_width - 2 * RACK_SUPPORT_WIDTH,
        rack_mounting_holes
            ? max(center_clearance, max_center_width_from_holes)
            : min(center_clearance, max_center_width_from_holes)
    );

    // Height limit: keep margin from nearest MakerRail slot cutout edge.
    nearest_slot_edge_to_center = rail_row_center_offset - T_SLOT_HEIGHT/2;
    max_center_height_from_slots = 2 * (nearest_slot_edge_to_center - CENTER_CUTOUT_SLOT_MARGIN);
    legacy_inner_height = max(1, height - 2 * (RACK_RAIL_HEIGHT + RACK_SUPPORT_WIDTH));
    center_open_height = min(height, max(legacy_inner_height, max_center_height_from_slots));

    difference() {
        // Main faceplate
        square([outer_width, height], center=true);

        // Top and bottom MakerRail slot rows
        translate([-center_open_width/2, rail_row_center_offset])
            maker_rail_2d(
                center_open_width,
                RACK_RAIL_HEIGHT,
                mounting_holes=false,
                base=false,
                edge_support_width=rail_edge_margin
            );
        translate([-center_open_width/2, -rail_row_center_offset])
            maker_rail_2d(
                center_open_width,
                RACK_RAIL_HEIGHT,
                mounting_holes=false,
                base=false,
                edge_support_width=rail_edge_margin
            );

        // Main center opening
        square([center_open_width, center_open_height], center=true);

        if (rack_mounting_holes) {
            rack_mount_holes_2d(rack_u, hole_c2c);
        }
    }
}

// ============================================
// Helper: Single spanning MakerRail (0U)
// ============================================
// Rotate the second rail 180 degrees to place rail centerlines exactly 1U apart.

module rack_single_rail_2d(
    outer_width,
    hole_c2c,
    center_clearance,
    rail_edge_margin=RACK_SUPPORT_WIDTH,
    rail_height=RACK_RAIL_HEIGHT
) {
    center_open_width = min(outer_width - 2 * RACK_SUPPORT_WIDTH, center_clearance);
    ear_width = (outer_width - center_open_width) / 2;
    ear_top = RACK_HOLE_EDGE_OFFSET
        + RACK_MOUNT_HOLE_DIAMETER/2
        + CENTER_CUTOUT_SIDE_MARGIN;
    ear_height = ear_top + rail_height/2;

    difference() {
        union() {
            square([outer_width, rail_height], center=true);
            translate([-outer_width/2, -rail_height/2])
                square([ear_width, ear_height]);
            translate([center_open_width/2, -rail_height/2])
                square([ear_width, ear_height]);
        }

        translate([-center_open_width/2, 0])
            maker_rail_2d(
                center_open_width,
                rail_height,
                mounting_holes=false,
                base=false,
                edge_support_width=rail_edge_margin
            );

        rack_mount_hole_pair_2d(
            RACK_HOLE_EDGE_OFFSET,
            hole_c2c,
            hole_d=RACK_MOUNT_HOLE_DIAMETER
        );
    }
}

// ============================================
// Module: 19" Rack Assembly
// ============================================

module rack_19(rack_u) {
    linear_extrude(height=PANEL_THICKNESS)
        rack_faceplate_2d(
            rack_u=rack_u,
            outer_width=RACK_19_OUTER_WIDTH,
            hole_c2c=RACK_19_MOUNT_C2C,
            center_clearance=RACK_19_CENTER_CLEARANCE
        );
}

module rack_19_2d(rack_u) {
    rack_faceplate_2d(
        rack_u=rack_u,
        outer_width=RACK_19_OUTER_WIDTH,
        hole_c2c=RACK_19_MOUNT_C2C,
        center_clearance=RACK_19_CENTER_CLEARANCE
    );
}

// ============================================
// Module: 10" Rack Assembly
// ============================================

module rack_10(rack_u) {
    linear_extrude(height=PANEL_THICKNESS)
        rack_faceplate_2d(
            rack_u=rack_u,
            outer_width=RACK_10_OUTER_WIDTH,
            hole_c2c=RACK_10_MOUNT_C2C,
            center_clearance=RACK_10_CENTER_CLEARANCE
        );
}

module rack_10_2d(rack_u) {
    rack_faceplate_2d(
        rack_u=rack_u,
        outer_width=RACK_10_OUTER_WIDTH,
        hole_c2c=RACK_10_MOUNT_C2C,
        center_clearance=RACK_10_CENTER_CLEARANCE
    );
}

if (part == "rack_19") {
    rack_19(rack_height_u);
} else if (part == "rack_19_2d") {
    rack_19_2d(rack_height_u);
} else if (part == "rack_10") {
    rack_10(rack_height_u);
} else if (part == "rack_10_2d") {
    rack_10_2d(rack_height_u);
}
