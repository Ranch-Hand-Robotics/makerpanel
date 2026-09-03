// Joystick panel design for MakerPanel
// This design creates a panel with a cutout for a joystick, 
// compatible with the MakerPanel.
// The reference design is for a SaiDian 4 Axis Mini Joystick Module, 
// which has a square base of 51mm x 51mm and a circular joystick area with a diameter of 15mm.
// The panel includes a cutout for the joystick and optional raised shapes for the buttons for visual
// reference when the joystick is installed. The panel can be laser cut or 3D printed, and is designed to fit within the MakerPanel system. 

include <panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, panel, panel_2d]
verticalUnits = 2; //[2:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 35; // [16:1:80] Minimum MakerPanel horizontal pitch (HP) for panel width
joystickCount = 2; // [1:1:3] Number of joystick holes to generate
e_stop = true; // Add an e-stop hole as the second control position
e_stop_diameter = 16; // [8:1:60] mm - diameter of the e-stop hole


/* [Hidden] */
module hidden() {}
circleInset = 10; // mm - inset from the outer slot positions. Positive values pull controls toward the center, negative values push them outward.
panel_depth = 3; // mm.

joystick_radius = 40/2; // mm, radius of the circular area for the joystick
joystick_mounting_hole_diameter = 3; // mm, diameter of the mounting holes for the joystick (M3)
joystick_mounting_hole_placement_radius = 22; // mm, radius at which the mounting holes are placed from the center of the joystick
outer_joystick_inset_extra_mm = 8; // mm, additional inset for the outermost joysticks
circleInsetExpansion = max(-circleInset, 0); // mm, extra outward spread when circleInset is negative
e_stop_radius = e_stop_diameter / 2; // mm, radius of the e-stop cutout
controlCount = joystickCount + (e_stop ? 1 : 0); // total number of control positions

// Geometry-based minimum footprint radius per joystick (includes mounting holes).
joystick_footprint_radius = max(joystick_radius, joystick_mounting_hole_placement_radius + joystick_mounting_hole_diameter / 2);
max_control_footprint_radius = max(joystick_footprint_radius, e_stop_radius); // mm, used for conservative spacing/edge clearance

// Non-configurable minimum panel width needed to place joystickCount controls
// while preserving edge clearance and non-overlapping spacing.
minimumPanelWidthMM = (controlCount == 1)
    ? (2 * max_control_footprint_radius)
    : (2 * max_control_footprint_radius * controlCount + 2 * outer_joystick_inset_extra_mm + 2 * circleInsetExpansion);
minimumHorizontalPitch = ceil(minimumPanelWidthMM / HP);

// Effective panel width accounts for joystick count and minimum geometry constraints,
// while still respecting the user-selected horizontalPitch as a floor.
effectiveHorizontalPitch = max(horizontalPitch, minimumHorizontalPitch);

module joystick_cutouts_2d_at(x_offset, y_offset=0) {
    // Cutout for the joystick
    translate([x_offset, y_offset])
        circle(r=joystick_radius, $fn=32);

    // Mounting holes for the joystick
    for (i = [0:3]) {
        angle = 45 + i * 90; // 4 holes at 45, 135, 225, 315 degrees
        x_hole_offset = x_offset + joystick_mounting_hole_placement_radius * cos(angle);
        y_hole_offset = y_offset + joystick_mounting_hole_placement_radius * sin(angle);
        translate([x_hole_offset, y_hole_offset])
            circle(r=joystick_mounting_hole_diameter/2, $fn=32);
    }
}

module e_stop_cutout_2d_at(x_offset, y_offset=0) {
    translate([x_offset, y_offset])
        circle(r=e_stop_radius, $fn=48);
}

function center_adjusted_x(base_x) = base_x == 0
    ? 0
    : (base_x > 0 ? 1 : -1) * max(abs(base_x) - circleInset, 0);

module joystick_panel_2d() {
    difference() {
        makerpanel_2d(effectiveHorizontalPitch, verticalUnits);

        // Distribute joystick cutouts evenly across the panel surface, with
        // geometry-safe edge clearance based on the largest control footprint.
        panel_width_mm = hp_to_mm(effectiveHorizontalPitch);
        if (controlCount == 1) {
            joystick_cutouts_2d_at(0, 0);
        } else {
            edge_clearance_mm = max_control_footprint_radius + outer_joystick_inset_extra_mm;
            usable_width_mm = panel_width_mm - 2 * edge_clearance_mm;
            spacing_mm = usable_width_mm / (controlCount - 1);
            for (slot = [0:controlCount-1]) {
                base_x_offset = -panel_width_mm / 2 + edge_clearance_mm + slot * spacing_mm;
                x_offset = center_adjusted_x(base_x_offset);
                if (e_stop && slot == 1) {
                    e_stop_cutout_2d_at(x_offset, 0);
                } else {
                    joystick_cutouts_2d_at(x_offset, 0);
                }
            }
        }
    }
}

module joystick_panel() {
    linear_extrude(height=panel_depth)
        joystick_panel_2d();
}

if (part == "assembly") {
    joystick_panel();
} else if (part == "panel") {
    joystick_panel();
} else if (part == "panel_2d") {
    joystick_panel_2d();
}