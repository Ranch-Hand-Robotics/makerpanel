// Antenna Panel
// This a MakerPanel has holes for Wifi, bluetooth, LoRA, or other antennas. 
// The MakerPanel is .25U in height by default, but configurable.

include <common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, panel, panel_2d]

horizontalPitch = 35; // [4:1:80] MakerPanel horizontal pitch (HP) for panel width
verticalUnits = .375; // [.5:.25:2] MakerPanel vertical units (U) for panel height

antenna_count = 4; // [1:1:16] Number of antenna pass-through holes
antenna_hole_diameter = 8; // [4:0.5:20] mm - antenna pass-through hole diameter
antenna_edge_inset = 30; // [2:1:40] mm - inset distance from left/right panel edges to first/last antenna hole centers

/* [Hidden] */
panel_depth = 3; // mm - panel thickness

function panel_width_mm() = hp_to_mm(horizontalPitch);
function edge_inset_mm() = max(antenna_edge_inset, 0);
function antenna_spacing() = antenna_count > 1
	? max((panel_width_mm() - 2 * edge_inset_mm()) / (antenna_count - 1), 0)
	: 0;

module antenna_holes_2d() {
	for (i = [0:antenna_count-1]) {
		x = (i - (antenna_count - 1) / 2) * antenna_spacing();
		translate([x, 0])
			circle(d=antenna_hole_diameter, $fn=48);
	}
}
module antenna_maker_panel_2d() {
	difference() {
		makerpanel_2d(horizontalPitch, verticalUnits);
		antenna_holes_2d();
	}
}

module antenna_maker_panel() {
	linear_extrude(height=panel_depth)
		antenna_maker_panel_2d();
}

if (part == "assembly") {
	antenna_maker_panel();
} else if (part == "panel") {
	antenna_maker_panel();
} else if (part == "panel_2d") {
	antenna_maker_panel_2d();
}


