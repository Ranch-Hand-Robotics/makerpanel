// =============================================================================
// MakerPanel Rail System - T-Slot Compatible Modules
// Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved.
// Licensed under MIT License: https://opensource.org/licenses/MIT
// ============================================================================
// All rail modules use standard T-slot nuts for universal compatibility
// Supports M5/M6 T-slot twist nuts and drop-in T-nuts
// ============================================================================

include <common.scad>

// ============================================
// Module: T-Slot Horizontal Cross-Rail
// ============================================
// Uses standard T-slot twist nuts (drop-in compatible)
// Slot geometry sized for M5/M6 T-slot nuts

module t_slot_crossrail(width, height=15, depth=12) {
    /*
    Creates a horizontal cross-rail with T-slot twist nut compatibility
    Parameters:
      - width: rail length in mm
      - height: rail height in mm
      - depth: rail depth (front to back) in mm
    */
    
    // Calculate number of slots that fit in the width
    num_slots = floor((width - 20) / T_SLOT_SPACING);
    first_slot_pos = (width - (num_slots - 1) * T_SLOT_SPACING) / 2;
    
    difference() {
        // Base solid block
        cube([width, height, depth], center=false);
        
        // Cut T-slot compatible slots (elongated rectangular)
        for (i = [0 : num_slots - 1]) {
            x_pos = first_slot_pos + i * T_SLOT_SPACING;
            translate([x_pos, -1, depth/2 - T_SLOT_WIDTH/2])
                cube([T_SLOT_LENGTH, height + 2, T_SLOT_WIDTH], center=false);
        }
    }
}

// ============================================
// Module: Rack Rail (Single)
// ============================================

module rack_rail(height) {
    /*
    Creates a single vertical rack rail with mounting holes
    Parameters:
      - height: rail height in mm (typically multiple of U)
    */
    
    // Calculate number of holes
    num_holes = floor(height / RACK_HOLE_SPACING);
    
    difference() {
        // Base rail
        cube([RACK_RAIL_WIDTH, height, RACK_RAIL_DEPTH]);
        
        // Mounting holes
        hole_start = RACK_HOLE_SPACING / 2;
        for (i = [0 : num_holes - 1]) {
            y_pos = hole_start + i * RACK_HOLE_SPACING;
            translate([RACK_RAIL_WIDTH/2, y_pos, -1])
                cylinder(r=RACK_HOLE_DIAMETER/2, h=RACK_RAIL_DEPTH + 2);
        }
    }
}

// ============================================
// Module: 19" Rack Assembly
// ============================================

module rack_19(height) {
    /*
    Creates a complete 19" rack frame
    Parameters:
      - height: total height in mm (typically multiple of U)
    */
    
    rack_custom(RACK_19_WIDTH, height);
}

// ============================================
// Module: 10" Rack Assembly
// ============================================

module rack_10(height) {
    /*
    Creates a complete 10" rack frame
    Parameters:
      - height: total height in mm (typically multiple of U)
    */
    
    rack_custom(RACK_10_WIDTH, height);
}

// ============================================
// Module: Custom Width Rack
// ============================================

module rack_custom(width, height) {
    /*
    Creates a rack with custom width
    Parameters:
      - width: outer width in mm
      - height: height in mm
    */
    
    usable = width - 2 * RACK_RAIL_WIDTH;
    
    // Left rail
    translate([0, 0, 0])
        rack_rail(height);
    
    // Right rail
    translate([width - RACK_RAIL_WIDTH, 0, 0])
        rack_rail(height);
    
    // Top support
    translate([RACK_RAIL_WIDTH, height - 20, 0])
        cube([usable, 20, RACK_RAIL_DEPTH]);
    
    // Bottom support
    translate([RACK_RAIL_WIDTH, 0, 0])
        cube([usable, 20, RACK_RAIL_DEPTH]);
}
