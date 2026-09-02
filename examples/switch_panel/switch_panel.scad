// Switch Panel
// This a MakerPanel has holes for switches, with an option for a switch cover 
// The MakerPanel is 1U in height by default, but configurable.

include <common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, panel, panel_2d]
horizontalPitch = 35; // [15:10:80] MakerPanel horizontal pitch (HP) for panel width
verticalUnits = 1; // [1:1:3] MakerPanel vertical units (U) for panel height
switch_count = 6; // [1:1:20] Number of switch pass-through holes
switch_hole_diameter = 12; // [4:0.5:30] Switch pass-through hole diameter in millimeters
switch_spacing = 20; // [12:1:40] Center-to-center spacing between switches in millimeters

/* [Hidden] */
switch_rail_buffer = 2; // [0:0.5:10] Clearance between switch hole edge and rail mount zone
panel_depth = 3; // [1:1:6] Panel thickness in millimeters

function switch_edge_inset_mm() = RACK_RAIL_HEIGHT + switch_rail_buffer + switch_hole_diameter / 2;
function switch_spacing_mm() = max(switch_spacing, switch_hole_diameter + switch_rail_buffer);
function minimum_panel_width_mm() = 2 * switch_edge_inset_mm()
	+ max(switch_count - 1, 0) * switch_spacing_mm();
function effective_horizontal_pitch() = max(horizontalPitch, ceil(minimum_panel_width_mm() / HP));

module switch_holes_2d() {
    for (i = [0 : switch_count - 1]) {
		x = (i - (switch_count - 1) / 2) * switch_spacing_mm();
		translate([x, 0])
			circle(d=switch_hole_diameter, $fn=32);
    }
}

module switch_panel_2d() {
	difference() {
		makerpanel_2d(effective_horizontal_pitch(), verticalUnits);
		switch_holes_2d();
	}
}

module switch_panel() {
	linear_extrude(height=panel_depth)
		switch_panel_2d();
}

if (part == "assembly") {
	switch_panel();
} else if (part == "panel") {
	switch_panel();
} else if (part == "panel_2d") {
	switch_panel_2d();
}
