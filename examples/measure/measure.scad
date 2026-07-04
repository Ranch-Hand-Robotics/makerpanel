// Maker Panel Measurement Guage
// This is a simple measurement guage for MakerPanel parts. It can be used to verify the dimensions of the 
// parts before cutting or assembling them. The parameters can be adjusted to match the 
// upper size of dimensions of the parts being measured.

// The idea for this is a panel that  includes measurements for major dimensions of panels, rails or racks, extruded from the XY plane
// with labels for the dimensions. The measurements are designed to be easily verifiable with calipers or a ruler, 
// and the labels are oriented to be easily read when the part is placed on top of the guage. The guage is designed to be 3D printed, allowing for 
// multiple colors with a layer modifier.
// Text is included for major dimensions.

// For example:
// A 4Ux35HP panel would be a 3mm thick panel with measurements for 1Ux9HP, 2Ux18HP, 3Ux27HP, and 4Ux35HP, with ticks at .5U and every 9HP with labels for major measurement. 
// A 35HP rail would be just as thick as 1 rail with horizontal ticks at every 9HP and have measurements for each HP with labels for major measurements. The ticks would be designed to be easily verifiable with calipers or a ruler, and the labels would be oriented to be easily read when the part is placed on top of the guage. NOTE: Holes are represnted by extruded cylinders not holes.
// A rack measurement panel would be 3mm thick with measurements for 1U, 2U, 3U and 4U (up to the max measurement_u), with ticks for .5U ticks and labels for each U; along with a ticks for HP at every HP, and labels for major HP measurements at every 9HP. The ticks would be designed to be easily verifiable with calipers or a ruler, and the labels would be oriented to be easily read when the part is placed on top of the guage.

// This file is not actually using MakerPanels, Rails or Racks, it is showing those measurements only.

include <common.scad>

/* [Part Selection] */
part = "panel"; // [panel, rail, rack]

/* [Parameters] */
panel_thickness = 3; // mm

verticalUnits = 4; // [1:1:8] MakerPanel vertical units (U) for panel/ruler height
horizontalPitch = 35; // [4:1:40] MakerPanel horizontal pitch (HP) for panel/ruler width
rack_type = "10"; // ["10", "19"] for 10" or 19" rack

module rail_ruler() {
    // This creates a rectangle with the dimensions of a rail and adds ticks and labels for measurements. The ticks, lines and text are 
    // raised above the base to be easily verifiable with calipers or a ruler. The text is oriented to be easily read when the part is placed on top of the guage.
    
    union() {
        // Base rectangle for the rail
        cube([hp_to_mm(horizontalPitch), 10, panel_thickness], center=false);
        
        // Ticks and labels for measurements
        for (i = [1:horizontalPitch-1]) {
            if (i % 9 == 0) {
                // Major measurement tick
                translate([hp_to_mm(i), 5, panel_thickness])
                    cube([2, 10, panel_thickness], center=true);
                // Label for major measurement
            } else {
                // Minor measurement tick
                translate([hp_to_mm(i), 2, panel_thickness])
                    cube([1, 3, panel_thickness], center=true);
            }
        }
    }
}

module panel_ruler() {
    // This creates a rectangle with the dimensions of a panel and adds ticks and labels for measurements. The ticks, lines and text are 
    // raised above the base to be easily verifiable with calipers or a ruler. The text is oriented to be easily read when the part is placed on top of the guage.
    
    union() {
        // Base rectangle for the panel
        cube([hp_to_mm(horizontalPitch), u_to_mm(verticalUnits), panel_thickness], center=false);
        
        // Bottom and right bars for each U section (top and left are open to panel edges)
        for (i = [1:verticalUnits]) {
            y_pos = u_to_mm(verticalUnits) - u_to_mm(i); // Y from bottom: bottom of section i from the top

            // Bottom bar: full width at the bottom of this U section
            translate([0, u_to_mm(i)-1, panel_thickness])
                cube([u_to_mm(i), 1, panel_thickness]);

            // Right bar: one U tall on the right side of this section
            translate([u_to_mm(i)-1, 0, panel_thickness])
                cube([1, u_to_mm(i), panel_thickness]);

            // Mounting hole bumps: 4 corners for each U measurement
            // All share the same bottom-left corner (origin at y=0)
            hole_inset = RACK_RAIL_HEIGHT / 2;
            bump_r = MOUNT_HOLE_DIAMETER / 2;
            bump_h = panel_thickness;
            
            // Each U section i extends from (0, 0) to (u_to_mm(i), u_to_mm(i))
            x_left = hole_inset;
            x_right = u_to_mm(i) - hole_inset;
            y_bottom = hole_inset;
            y_top = u_to_mm(i) - hole_inset;
            
            // 4 corner holes for this U section
            for (cx = [x_left, x_right], cy = [y_bottom, y_top]) {
                translate([cx, cy, panel_thickness])
                    cylinder(r=bump_r, h=bump_h, $fn=32);
            }
        }
    }
}


if (part == "panel") {
    panel_ruler();
} else if (part == "rail") {
    rail_ruler();
    
} else {
    rack_ruler();
}
