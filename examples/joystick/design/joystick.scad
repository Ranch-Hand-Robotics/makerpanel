// Joystick panel design for MakerPanel
// This design creates a panel with a cutout for a joystick, 
// compatible with the MakerPanel.
// The reference design is for a SaiDian 4 Axis Mini Joystick Module, 
// which has a square base of 51mm x 51mm and a circular joystick area with a diameter of 15mm.
// The panel includes a cutout for the joystick and optional raised shapes for the buttons for visual
// reference when the joystick is installed. The panel can be laser cut or 3D printed, and is designed to fit within the MakerPanel system. 

include <panel.scad>

/* [Parameters] */
verticalUnits = 2; //[2:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 17; // [17:4:80] Minimum MakerPanel horizontal pitch (HP) for panel width
panel_depth = 3; // mm.
joystickCount = 1; // [1:1:3] Number of joystick holes to generate

module hidden() {}

joystick_radius = 40/2; // mm, radius of the circular area for the joystick
joystick_mounting_hole_diameter = 3; // mm, diameter of the mounting holes for the joystick (M3)
joystick_mounting_hole_placement_radius = 22; // mm, radius at which the mounting holes are placed from the center of the joystick
outer_joystick_inset_extra_mm = 8; // mm, additional inset for the outermost joysticks

// Geometry-based minimum footprint radius per joystick (includes mounting holes).
joystick_footprint_radius = max(joystick_radius, joystick_mounting_hole_placement_radius + joystick_mounting_hole_diameter / 2);

// Non-configurable minimum panel width needed to place joystickCount controls
// while preserving edge clearance and non-overlapping spacing.
minimumPanelWidthMM = (joystickCount == 1)
    ? (2 * joystick_footprint_radius)
    : (2 * joystick_footprint_radius * joystickCount + 2 * outer_joystick_inset_extra_mm);
minimumHorizontalPitch = ceil(minimumPanelWidthMM / HP);

// Effective panel width accounts for joystick count and minimum geometry constraints,
// while still respecting the user-selected horizontalPitch as a floor.
effectiveHorizontalPitch = max(horizontalPitch, minimumHorizontalPitch);

module joystick_cutouts_at(x_offset, y_offset=0) {
    // Cutout for the joystick
    translate([x_offset, y_offset, -1])
        linear_extrude(height=panel_depth + 2)
            circle(r=joystick_radius, $fn=32);

    // Mounting holes for the joystick
    for (i = [0:3]) {
        angle = 45 + i * 90; // 4 holes at 45, 135, 225, 315 degrees
        x_hole_offset = x_offset + joystick_mounting_hole_placement_radius * cos(angle);
        y_hole_offset = y_offset + joystick_mounting_hole_placement_radius * sin(angle);
        translate([x_hole_offset, y_hole_offset, -1])
            linear_extrude(height=panel_depth + 2)
                circle(r=joystick_mounting_hole_diameter/2, $fn=32);
    }
}

module joystick_panel() {
    // 3D printable panel (same XY geometry as laser version, extruded in Z)
    difference() {
        makerpanel(effectiveHorizontalPitch, verticalUnits, thickness=panel_depth);

        // Distribute joystick cutouts evenly across the panel surface, with
        // geometry-safe edge clearance based on joystick_footprint_radius.
        panel_width_mm = hp_to_mm(effectiveHorizontalPitch);
        if (joystickCount == 1) {
            joystick_cutouts_at(0, 0);
        } else {
            edge_clearance_mm = joystick_footprint_radius + outer_joystick_inset_extra_mm;
            usable_width_mm = panel_width_mm - 2 * edge_clearance_mm;
            spacing_mm = usable_width_mm / (joystickCount - 1);
            for (j = [0:joystickCount-1]) {
                x_offset = -panel_width_mm / 2 + edge_clearance_mm + j * spacing_mm;
                joystick_cutouts_at(x_offset, 0);
            }
        }
    }
}

joystick_panel();