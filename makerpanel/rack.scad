// Maker Panel Adapter for Standard Racks
// This module defines the rack panels for standard 19" and 10" racks, with support for T-slot mounting 
// and customizable hole patterns. The panels are designed to fit within the MakerPanel system, allowing 
// for modular integration of components while maintaining compatibility with standard rack equipment. The rack panels can be customized 
// in width (19" or 10"), height (in U), and hole patterns to accommodate various mounting needs.

include <common.scad>
include <rails.scad>

part = "rack_19"; // [rack_19, rack_10, rack_19_2d, rack_10_2d]

rack_height_u = 2; // Height of the rack in Standard Rack Units

// Rack faceplate dimensions (EIA style)
RACK_19_OUTER_WIDTH = 482.6;      // 19.000"
RACK_19_MOUNT_C2C = 465.1;        // 18.312" center-to-center between left/right rack rails
RACK_19_CENTER_CLEARANCE = 450;   // Practical center opening for adapter body

RACK_10_OUTER_WIDTH = 254;        // 10.000"
RACK_10_MOUNT_C2C = 236.525;      // 9.312" center-to-center between left/right rack rails
RACK_10_CENTER_CLEARANCE = 220;   // Practical center opening for adapter body

// 10" Rack Dimensions:
// Height Unit (1U): 44.45mm (1.75") - identical to standard 19" racks
// Width between 10" mounting holes: 236.525mm (9.312")
// Maximum horizontal clearance: 220mm (8.75")
// Recommended equipment width: 210mm (8.45") for proper fit with tolerance


// 19" Rack Dimensions:
// Height Unit (1U): 44.45mm (1.75")
// Width between 19" mounting holes: 482.6mm (19")
// Maximum horizontal clearance: 465.1mm (18.3")
// Recommended equipment width: 450mm (17.7") for proper fit with tolerance


// Standard 1U Rack Hole pattern parameters. 
// Holes are M6 threaded, with a horizontal pitch of 15.875mm (5/8") and a vertical pitch of 12.7mm (1/2").
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

module rack_mount_holes_2d(rack_u, hole_c2c, slot_len=8, hole_d=6.5) {
    height = u_to_mm(rack_u);
    y_min = -height/2;

    // Per-U EIA vertical hole positions (from each U start)
    hole_offsets = [6.35, 22.225, 38.1];

    for (u_idx = [0 : rack_u - 1]) {
        for (offset = hole_offsets) {
            y = y_min + u_idx * U + offset;

            // Left ear
            translate([-hole_c2c/2, y])
                obround_slot_2d(slot_len, hole_d);

            // Right ear
            translate([hole_c2c/2, y])
                obround_slot_2d(slot_len, hole_d);
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
