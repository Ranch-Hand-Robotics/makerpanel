// Monitor Panel
// This file builds an independent MakePanel for mounting a VESA monitor to a MakerRail.
// The panel is designed to have a pivot centered on the panel width and toward the top in height.
// The pivot is connected to an arm, which itself is conneted to the VESA mount on the back of the monitor. 
// The panel can be installed in a MakerRail compatible case or cyberdeck.

// Customization options
// Arm length, arm width, and arm thickness can be adjusted to fit the monitor and desired pivot point.
// The pivot on the MakerPanel and VESA mount are GoPro mount compatible and can use GoPro thumbscrews for adjustment.
// The arm can have an optional 3rd pivot point between the VESA mount and the MakerPanel pivot, allowing for more flexibility in positioning the monitor.


include <common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, maker_panel, vesa_panel, arm, pivot]

panel_depth = 3; // mm - thickness of the panel
verticalUnits = 1; // [1:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 35; // [4:1:40] MakerPanel horizontal pitch (HP) for panel width

arm_length = 100; // mm - length of the arm connecting the panel to the VESA mount
arm_width = 20; // mm - width of the arm connecting the panel to the VESA mount
arm_thickness = 3; // mm - thickness of the arm connecting the panel to the VESA mount

/* [Hidden] */
pivot_radius = 10; // mm - radius of the pivot cylinder
pivot_bolt_radius = 2.7; // mm - radius of the bolt hole in the pivot cylinder
pivot_block_height = 20; // mm - height of the block that connects the pivot to the MakerPanel
pivot_block_base_width = 50; // mm - width of the base of the block that connects the pivot to the MakerPanel
pivot_blade_thickness = 5; // mm - thickness of the pivot blade that connects the pivot to the MakerPanel
pivot_blade_count = 3; // number of pivot blades that connect the pivot to the MakerPanel

pivot_nut_radius = 5; // mm - radius of the nut hole in the pivot cylinder
pivot_nut_height = 8; // mm - height of the nut hole in the pivot cylinder

panel_pivot_spacing = 20; // mm - spacing between the pivots on the panel

function pivot_height() = pivot_blade_thickness * (pivot_blade_count * 2); // mm - height of the pivot cylinder, based on the number of blades and their thickness

// Pivot for the MakerPanel and VESA mount
// The pivot is a cylinder with a hole for a thumbscrew, allowing for adjustment of the monitor angle.
module pivot(base_width=pivot_block_base_width) {
    pivot_height = pivot_height();

    // Bottom of the pivot block should be at [0,0,0]
    translate([pivot_height/2,0,pivot_block_height])
    rotate([0, -90, 0])
    difference() {
        union() {
            // Main Pivot cylinder
            cylinder(r=pivot_radius, h=pivot_height, $fn=32);
            
            // Triangular gusset tangent to the left side of the pivot cylinder
            linear_extrude(height=pivot_height)
                polygon(points=[
                    [-pivot_block_height, -base_width/2],
                    [-pivot_block_height,  base_width/2],
                    [pivot_radius, 0]
                ]);

            // Extend the main pivot cylinder with a Rounded Cylinder end cap to capture the nut and bolt for the thumbscrew.
            translate([0, 0, -pivot_height/2+pivot_nut_height+1])
                union() {
                    translate([0, 0, 1])
                        cylinder(r=pivot_radius, h=pivot_nut_height-3, $fn=32);
                    cylinder(r=pivot_radius-1, h=pivot_nut_height-3, $fn=32);
                    rotate_extrude($fn=48)
                        translate([pivot_radius-1, 1])
                            circle(r=1, $fn=24);
                    rotate_extrude($fn=48)
                        translate([pivot_radius-1, pivot_nut_height-1])
                            circle(r=1, $fn=24);
                }
            }
        union() {

            // This is the bolt clearance hole.
            cylinder(r=pivot_bolt_radius, h=pivot_height*5, $fn=32, center=true);

            // Subtract a hexagonal hole for for an m5 bolt. The hexagon is oriented parallel to the pivot cylinder axis.
            translate([0,0,-pivot_height/2+pivot_nut_height/2])
                cylinder(r=pivot_nut_radius, h=pivot_nut_height, $fn=6);

            // Subtract vertical blade slots, evenly spaced across the pivot diameter (±X).
            for (i = [0:pivot_blade_count-1]) {
                blade_pos = i * pivot_blade_thickness * 2 + pivot_blade_thickness; 
                translate([0, 0, blade_pos])
                    cube([pivot_radius*2, base_width,pivot_blade_thickness], center=true);
            }
        }
    }
}


module monitor_maker_panel() {

    union() {
        // 3D printable panel - flat surface with T-slot mounting holes
        makerpanel(horizontalPitch, verticalUnits, thickness=panel_depth);
        pivot_height = pivot_height();

        translate([panel_pivot_spacing /2 + pivot_height/2, 0, panel_depth])
        rotate([0, 0, 180])
        pivot(u_to_mm(verticalUnits));

        translate([-panel_pivot_spacing /2 - pivot_height/2, 0, panel_depth])
        pivot(u_to_mm(verticalUnits));
    }
}

module vesa_panel() {
    pivot_height = pivot_height();

    // VESA Mounting holes (100mm x 100mm)
    vesa_hole_spacing = 100; // mm
    vesa_hole_radius = 3; // mm
    vesa_width = vesa_hole_spacing + 2*vesa_hole_radius + 8;

    union() {
        difference() {
            cube([vesa_width, vesa_width, panel_depth], center=true);

            translate([-vesa_hole_spacing/2, -vesa_hole_spacing/2, -1])
                linear_extrude(height=panel_depth*3, center=true)
                    for (i = [0:1], j = [0:1]) {
                        translate([i * vesa_hole_spacing, j * vesa_hole_spacing])
                            circle(r=vesa_hole_radius, $fn=32);
                    }
        }

        translate([panel_pivot_spacing /2 + pivot_height/2, 0, 0])
        rotate([0, 0, 180])
        pivot(vesa_width/2);

        translate([-panel_pivot_spacing /2 - pivot_height/2, 0, 0])
        pivot(vesa_width/2);
    }
}

module monitor_arm() {
    arm_blade_thickness = pivot_blade_thickness - 0.5;
    rotate([0, 90, 0])
    difference() {
        // Subtract vertical blade slots, evenly spaced across the pivot diameter (±X).
        for (i = [0:0]) {
            blade_pos = i * pivot_blade_thickness * 2 + pivot_blade_thickness; 
            translate([0, 0, blade_pos])
                hull() {
                    translate([0, -(arm_length/2 - pivot_radius), 0])
                        cylinder(r=pivot_radius, h=arm_blade_thickness, center=true, $fn=48);
                    translate([0,  (arm_length/2 - pivot_radius), 0])
                        cylinder(r=pivot_radius, h=arm_blade_thickness, center=true, $fn=48);
                }
        }

        // This is the bolt clearance hole.
        translate([0, -(arm_length/2 - pivot_radius), 0])
        cylinder(r=pivot_bolt_radius, h=arm_blade_thickness * pivot_blade_count * 2, $fn=32, center=false);

        translate([0,  (arm_length/2 - pivot_radius), 0])
        cylinder(r=pivot_bolt_radius, h=arm_blade_thickness * pivot_blade_count * 2, $fn=32, center=false);
    }
}


if (part == "assembly") {
    pivot_height = pivot_height();
    monitor_maker_panel();

    translate([0, pivot_height, arm_length])
    rotate([90, 0, 0])
    vesa_panel();

    rotate([90, 0, 0])
    translate([0, arm_length/2 + pivot_height/2, 0])
    monitor_arm();
} else if (part == "maker_panel") {
    monitor_maker_panel();
} else if (part == "vesa_panel") {
    vesa_panel();
} else if (part == "arm") {
    monitor_arm();
} else if (part == "pivot") {
    pivot();
}





