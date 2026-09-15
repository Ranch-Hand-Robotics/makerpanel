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
    half_w = width_mm / 2;
    half_h = height_mm / 2;
    
    // Calculate mounting hole positions
    // For panels <1U: one centered hole per side (left/right)
    // For panels >=1U: four corner holes
    hole_inset_x = RACK_RAIL_HEIGHT / 2;
    hole_inset_y = RACK_RAIL_HEIGHT / 2;
    
    difference() {
        // Base panel
        square([width_mm, height_mm], center=true);
        
        if (height_u < 1) {
            // Sub-1U: one centered mounting hole on each side
            translate([-(half_w - hole_inset_x), 0])
                circle(r=mount_hole_diameter/2, $fn=32);

            translate([(half_w - hole_inset_x), 0])
                circle(r=mount_hole_diameter/2, $fn=32);
        } else {
            // 1U and larger: 4 corner mounting holes (M3 for T-nuts)
            // Bottom-left
            translate([-(half_w - hole_inset_x), -(half_h - hole_inset_y)])
                circle(r=mount_hole_diameter/2, $fn=32);

            // Bottom-right
            translate([(half_w - hole_inset_x), -(half_h - hole_inset_y)])
                circle(r=mount_hole_diameter/2, $fn=32);

            // Top-left
            translate([-(half_w - hole_inset_x), (half_h - hole_inset_y)])
                circle(r=mount_hole_diameter/2, $fn=32);

            // Top-right
            translate([(half_w - hole_inset_x), (half_h - hole_inset_y)])
                circle(r=mount_hole_diameter/2, $fn=32);
        }
    }
}

// Extrude a finished 2D panel profile without beveling its internal cutouts.
// size is the centered rectangular outside envelope. An optional second
// child supplies a nonrectangular, hole-free, axis-aligned outside outline.
// The bottom chamfer_start mm remain straight; higher edges slope at 45 deg.
module panel_extrude(size, thickness, chamfer_start=1.2) {
    start = is_undef(chamfer_start) ? thickness : max(0, chamfer_start);
    bevel = max(0, thickness - start);

    if (bevel == 0)
        linear_extrude(height=thickness) children(0);
    else if ($children > 1)
        difference() {
            linear_extrude(height=thickness) children(0);
            // Expand only the exterior into the plate as Z increases.
            // A square pyramid gives exact 45-degree orthogonal faces,
            // including the concave corners of the rack rail's ears.
            translate([0, 0, start])
                minkowski() {
                    linear_extrude(height=thickness)
                        difference() {
                            offset(delta=bevel) children(1);
                            children(1);
                        }
                    polyhedron(
                        points=[
                            [0, 0, 0],
                            [-bevel, -bevel, bevel],
                            [ bevel, -bevel, bevel],
                            [ bevel,  bevel, bevel],
                            [-bevel,  bevel, bevel]
                        ],
                        faces=[
                            [0, 2, 1], [0, 3, 2],
                            [0, 4, 3], [0, 1, 4], [1, 2, 3, 4]
                        ],
                        convexity=4
                    );
                }
        }
    else
        intersection() {
            linear_extrude(height=thickness) children(0);
            union() {
                if (start > 0)
                    linear_extrude(height=start)
                        square(size, center=true);
                translate([0, 0, start])
                    linear_extrude(
                        height=bevel,
                        scale=[
                            max(0, size.x - 2*bevel)/size.x,
                            max(0, size.y - 2*bevel)/size.y
                        ]
                    )
                        square(size, center=true);
            }
        }
}

module makerpanel(width_hp, height_u, thickness=PANEL_THICKNESS,
    mount_hole_diameter=MOUNT_HOLE_DIAMETER, chamfer_start=undef) {
    /*
    Creates a maker panel with T-slot mounting holes (M5/M6 compatible)
    Parameters:
      - width_hp: width in HP units
      - height_u: height in U units
      - thickness: panel thickness in mm (default 3mm aluminum)
            - mount_hole_diameter: mounting hole diameter in mm (default from common.scad)
    */
    panel_extrude(
        [hp_to_mm(width_hp), u_to_mm(height_u)],
        thickness,
        chamfer_start=chamfer_start
    )
        makerpanel_2d(width_hp, height_u, mount_hole_diameter=mount_hole_diameter);
}
