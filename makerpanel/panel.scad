// Makerpanel System OpenSCAD Models
// Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved.
// Licensed under MIT License: https://opensource.org/licenses/MIT
// Modular maker panel system with rack mounting support
// All dimensions in millimeters
include <common.scad>

// ============================================
// Module: Panel with T-Slot Mounting Holes
// ============================================

module makerpanel_2d(width_hp, height_u, mount_hole_diameter=MOUNT_HOLE_DIAMETER) {
    /*
        Creates a 2D maker panel profile with T-slot mounting holes (M5/M6 compatible)
    Parameters:
      - width_hp: width in HP units
      - height_u: height in U units
            - mount_hole_diameter: mounting hole diameter in mm (default from common.scad)
    */
    
    width_mm = hp_to_mm(width_hp);
    height_mm = u_to_mm(height_u);
    
    // Calculate mounting hole positions - 4 holes at corners
    // Centered within RACK_RAIL_HEIGHT from each edge
    hole_inset_x = RACK_RAIL_HEIGHT / 2;
    hole_inset_y = RACK_RAIL_HEIGHT / 2;
    
    difference() {
        // Base panel
        square([width_mm, height_mm], center=false);
        
        // 4 corner mounting holes (M3 for T-nuts)
        // Bottom-left
        translate([hole_inset_x, hole_inset_y])
            circle(r=mount_hole_diameter/2, $fn=32);
        
        // Bottom-right
        translate([width_mm - hole_inset_x, hole_inset_y])
            circle(r=mount_hole_diameter/2, $fn=32);
        
        // Top-left
        translate([hole_inset_x, height_mm - hole_inset_y])
            circle(r=mount_hole_diameter/2, $fn=32);
        
        // Top-right
        translate([width_mm - hole_inset_x, height_mm - hole_inset_y])
            circle(r=mount_hole_diameter/2, $fn=32);
    }
}

module makerpanel(width_hp, height_u, thickness=PANEL_THICKNESS, mount_hole_diameter=MOUNT_HOLE_DIAMETER) {
    /*
    Creates a maker panel with T-slot mounting holes (M5/M6 compatible)
    Parameters:
      - width_hp: width in HP units
      - height_u: height in U units
      - thickness: panel thickness in mm (default 3mm aluminum)
            - mount_hole_diameter: mounting hole diameter in mm (default from common.scad)
    */
    linear_extrude(height=thickness)
                makerpanel_2d(width_hp, height_u, mount_hole_diameter=mount_hole_diameter);
}
