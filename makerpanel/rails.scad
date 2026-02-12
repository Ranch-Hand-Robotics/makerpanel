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
// Helper: Rounded Cube
// ============================================

module rounded_cube(size, r=1) {
    /*
    Creates a cube with rounded edges
    Parameters:
      - size: [width, height, depth] or single value
      - r: corner radius
    */
    s = is_list(size) ? size : [size, size, size];
    
    hull() {
        for (x = [r, s[0] - r])
            for (y = [r, s[1] - r])
                for (z = [r, s[2] - r])
                    translate([x, y, z])
                        sphere(r=r, $fn=16);
    }
}

// ============================================
// Module: T-Slot Horizontal Cross-Rail
// ============================================
// Uses standard T-slot twist nuts (drop-in compatible)
// Slot geometry sized for M5/M6 T-slot nuts


module maker_rail(rail_width, height=RACK_RAIL_HEIGHT, depth=RACK_RAIL_THICKNESS, mounting_holes=true) {
    /*
    Creates a horizontal cross-rail with T-slot twist nut compatibility
    Parameters:
      - rail_width: rail length in mm
      - height: rail height in mm
      - depth: rail depth (front to back) in mm
    */

    rail_offset = mounting_holes? (-height/2) : 0;
    width = mounting_holes ? rail_width + height/2 : rail_width;
    
    // Available space between mounting holes (equal spacing on both sides)
    available_space = mounting_holes ? (width - 2 * height) : (width - 2 * RACK_SUPPORT_WIDTH);
    
    // Calculate number of slots that fit with minimum spacing
    min_spacing = T_SLOT_WIDTH + RACK_SUPPORT_WIDTH;
    num_slots = floor((available_space + RACK_SUPPORT_WIDTH) / min_spacing);
    
    // Calculate minimum space needed
    min_space_needed = num_slots * T_SLOT_WIDTH + (num_slots - 1) * RACK_SUPPORT_WIDTH;
    
    // Calculate extra space and distribute proportionately among slots
    extra_space = available_space - min_space_needed;
    actual_slot_width = T_SLOT_WIDTH + (extra_space / num_slots);
    
    // First slot starts at height (equal distance from mounting hole to slot and hole to wall)
    first_slot_pos = mounting_holes ? height : RACK_SUPPORT_WIDTH;
    
    // Spacing between slots (center to center)
    actual_spacing = actual_slot_width + RACK_SUPPORT_WIDTH;
   
    difference() 
    {
        // Base solid block  
        translate([rail_offset, -height/2, 0])
            cube([width, height, depth], center=false);
        
        // Cut T-slot compatible slots (elongated rectangular)
        for (i = [0 : num_slots - 1]) {
            x_pos = first_slot_pos + i * actual_spacing;
            translate([x_pos + rail_offset, -T_SLOT_HEIGHT/2, -depth/2])
                rounded_cube([actual_slot_width, T_SLOT_HEIGHT, depth*2], r=T_SLOT_CORNER_RADIUS);
        }
        
        // Mounting holes on either side
        if (mounting_holes) {
            // Left mounting hole
            translate([height/2 + rail_offset, 0, -1])
                cylinder(r=RACK_HOLE_DIAMETER/2, h=depth + 2, $fn=32);
            
            // Right mounting hole
            translate([width - height/2 + rail_offset, 0, -1])
                cylinder(r=RACK_HOLE_DIAMETER/2, h=depth + 2, $fn=32);
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
    
    rail_width = RACK_RAIL_HEIGHT;  // Using existing variable
    
    // Left rail - vertical, centered at x=0
    rotate([0, 0, 90])
        maker_rail(height, height=rail_width, depth=RACK_RAIL_THICKNESS, mounting_holes=false);
    
    // Right rail - vertical, centered at x=width
    translate([width - rail_width/2, 0, 0])
        rotate([0, 0, 90])
            maker_rail(height, height=rail_width, depth=RACK_RAIL_THICKNESS, mounting_holes=false);
}
