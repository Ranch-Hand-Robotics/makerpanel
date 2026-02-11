// Makerpanel System OpenSCAD Models
// Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved.
// Licensed under MIT License: https://opensource.org/licenses/MIT
// Modular maker panel system with rack mounting support
// All dimensions in millimeters
include <common.scad>

// ============================================
// Module: Panel with T-Slot Mounting Holes
// ============================================

module makerpanel(width_hp, height_u, thickness=PANEL_THICKNESS) {
    /*
    Creates a maker panel with T-slot mounting holes (M5/M6 compatible)
    Parameters:
      - width_hp: width in HP units
      - height_u: height in U units
      - thickness: panel thickness in mm (default 3mm aluminum)
    */
    
    width_mm = hp_to_mm(width_hp);
    height_mm = u_to_mm(height_u);
    
    // Calculate mounting hole positions
    // Holes positioned to align with T-slot centers (25mm spacing)
    hole_spacing = T_SLOT_SPACING;
    num_holes_h = floor(width_mm / hole_spacing);
    num_holes_v = max(1, floor(height_mm / hole_spacing));
    
    hole_start_x = (width_mm - (num_holes_h - 1) * hole_spacing) / 2;
    hole_start_y = (height_mm - (num_holes_v - 1) * hole_spacing) / 2;
    
    difference() {
        // Base panel
        cube([width_mm, height_mm, thickness], center=false);
        
        // T-slot mounting holes (vertical holes for M5/M6 T-nuts)
        for (i = [0 : num_holes_h - 1]) {
            for (j = [0 : num_holes_v - 1]) {
                x_pos = hole_start_x + i * hole_spacing;
                y_pos = hole_start_y + j * hole_spacing;
                
                // Only create holes near edges (2cm border minimum)
                if (x_pos >= 20 && x_pos <= width_mm - 20 &&
                    y_pos >= 20 && y_pos <= height_mm - 20) {
                    translate([x_pos, y_pos, -1])
                        cylinder(r=MOUNT_HOLE_DIAMETER/2, h=thickness + 2);
                }
            }
        }
    }
}
