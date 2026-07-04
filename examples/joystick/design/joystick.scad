// Joystick panel design for MakerPanel
// This design creates a panel with a cutout for a joystick, 
// compatible with the MakerPanel.
// The reference design is for a SaiDian 4 Axis Mini Joystick Module, 
// which has a square base of 51mm x 51mm and a circular joystick area with a diameter of 15mm.
// The panel includes a cutout for the joystick and optional raised shapes for the buttons for visual
// reference when the joystick is installed. The panel can be laser cut or 3D printed, and is designed to fit within the MakerPanel system. 

include <panel.scad>

/* [Parameters] */
verticalUnits = 2; //[1:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 17; // [4:1:40] MakerPanel horizontal pitch (HP) for panel width (17HP is 89.25mm, which is slightly larger than the 51mm square base of the joystick, allowing for tolerance and mounting holes)
joystick_panel_depth = 3; // mm.

module hidden() {}

joystick_radius = 40/2; // mm, radius of the circular area for the joystick
joystick_mounting_hole_diameter = 3; // mm, diameter of the mounting holes for the joystick (M3)
joystick_mounting_hole_placement_radius = 22; // mm, radius at which the mounting holes are placed from the center of the joystick

module joystick_panel() {
    // 3D printable panel (same XY geometry as laser version, extruded in Z)
    difference() {
        makerpanel(horizontalPitch, verticalUnits, thickness=joystick_panel_depth);

        // Cutout for the joystick
        translate([0, 0, -1])
            linear_extrude(height=joystick_panel_depth + 2)
                circle(r=joystick_radius, $fn=32);

        // Mounting holes for the joystick
        for (i = [0:3]) {
            angle = 45 + i * 90; // 4 holes at 45, 135, 225, 315 degrees
            x_offset = joystick_mounting_hole_placement_radius * cos(angle);
            y_offset = joystick_mounting_hole_placement_radius * sin(angle);
            translate([x_offset, y_offset, -1])
                linear_extrude(height=joystick_panel_depth + 2)
                    circle(r=joystick_mounting_hole_diameter/2, $fn=32);
        }
    }
}

joystick_panel();