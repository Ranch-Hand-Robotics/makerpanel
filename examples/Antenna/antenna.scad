// Antenna Panel
// This a MakerPanel has holes for Wifi, bluetooth, LoRA, or other antennas. 
// The MakerPanel is .25U in height by default, but configurable.

include <common.scad>
include <makerpanel/panel.scad>
use <examples/vent_panel/IsoGridScad/isogrid.scad>

/* [Customization] */
part = "assembly"; // [assembly, panel, panel_2d]

horizontalPitch = 35; // [4:1:80] MakerPanel horizontal pitch (HP) for panel width
verticalUnits = 1; // [1:.25:2] MakerPanel vertical units (U) for panel height
antenna_count = 4; // [1:1:16] Number of antenna pass-through holes
sdr_module = "KerberosSDR"; // [none, bladeRF, LimeSDR, HackRF, KrakenSDR, KerberosSDR] SDR module to fit in panel cutout

/* [Hidden] */
antenna_hole_diameter = 8; // [4:0.5:20] mm - antenna pass-through hole diameter
antenna_edge_inset = 30; // [2:1:40] mm - inset distance from left/right panel edges to first/last antenna hole centers
antenna_rail_buffer = 2; // [0:0.5:10] mm - clearance between each antenna hole edge and the rail mount zone
antenna_device_gap = 10; // [10:1:30] mm - clearance from antenna hole edge to SDR enclosure
isogrid_triangle_size = 17; // [8:1:30] mm - SDR panel IsoGrid triangle size
isogrid_rib_thickness = 1.5; // [0.8:0.1:4] mm - SDR panel IsoGrid rib thickness
isogrid_antenna_buffer = 2; // [1:0.5:10] mm - solid material around antenna holes
kerberos_mount_hole_diameter = 3; // [2:0.5:5] mm - KerberosSDR mounting screw through-hole
kerberos_mount_pad_diameter = 12; // [8:1:20] mm - reinforced area around each mounting screw
kerberos_mount_recess_diameter = 6; // [4:0.5:10] mm - recessed screw-head diameter
kerberos_mount_recess_depth = 1.5; // [0.5:0.25:2.5] mm - recessed screw-head depth

panel_depth = 3; // mm - panel thickness
sdr_edge_clearance = 2; // mm - minimum clearance around the SDR footprint
epsilon = 0.01;

// SDR data: [width, height, antenna count]. KerberosSDR's 25.4 mm enclosure
// depth does not affect the panel footprint calculation.
function sdr_data(module_name) =
	module_name == "bladeRF" ? [63, 102, 4] :
	module_name == "LimeSDR" ? [100, 60, 10] :
	module_name == "HackRF" ? [120, 75, 1] :
	module_name == "KrakenSDR" ? [177.3, 113.5, 5] :
	module_name == "KerberosSDR" ? [130, 90, 4] :
	[0, 0, antenna_count];

function round_up(value, increment) = ceil(value / increment) * increment;
function sdr_enabled() = sdr_module != "none";
function sdr_width_mm() = sdr_data(sdr_module)[0];
function sdr_height_mm() = sdr_data(sdr_module)[1];
function effective_antenna_count() = sdr_data(sdr_module)[2];
function antenna_edge_offset_mm() = RACK_RAIL_HEIGHT + antenna_rail_buffer + antenna_hole_diameter / 2;
function compact_antenna_offset_mm() = min(
	antenna_rail_buffer,
	max(panel_height_mm() / 2 - antenna_hole_diameter / 2 - sdr_edge_clearance, 0)
);
function antenna_row_minimum_mm() = effective_antenna_count() > 1
	? 2 * edge_inset_mm() + (effective_antenna_count() - 1) * antenna_hole_diameter
	: antenna_hole_diameter;
function sdr_antenna_axis_mm() = max(sdr_width_mm(), antenna_row_minimum_mm());
function required_hp(width) = ceil((width + 2 * sdr_edge_clearance) / HP);
function required_u(height) = round_up((height + 2 * sdr_edge_clearance) / U, 0.25);
function antenna_center_to_device_edge_mm() = antenna_hole_diameter / 2 + antenna_device_gap;
function required_perpendicular_span_mm() = antenna_edge_offset_mm()
	+ antenna_center_to_device_edge_mm() + sdr_height_mm() + sdr_edge_clearance;
function required_perpendicular_hp() = ceil(required_perpendicular_span_mm() / HP);
function required_perpendicular_u() = round_up(required_perpendicular_span_mm() / U, 0.25);

// Prefer preserving horizontalPitch. If both orientations need more width,
// choose the narrower orientation; use the shorter panel as the tie-breaker.
function native_panel_hp() = max(horizontalPitch, required_hp(sdr_antenna_axis_mm()));
function native_panel_u() = max(verticalUnits, required_perpendicular_u());
function rotated_panel_hp() = max(horizontalPitch, required_perpendicular_hp());
function rotated_panel_u() = max(verticalUnits, required_u(sdr_antenna_axis_mm()));
function rotate_sdr() = sdr_enabled() &&
	(rotated_panel_hp() < native_panel_hp() ||
		(rotated_panel_hp() == native_panel_hp() && rotated_panel_u() < native_panel_u()));
function effective_horizontal_pitch() = !sdr_enabled() ? horizontalPitch :
	(rotate_sdr() ? rotated_panel_hp() : native_panel_hp());
function effective_vertical_units() = !sdr_enabled() ? verticalUnits :
	(rotate_sdr() ? rotated_panel_u() : native_panel_u());

function panel_width_mm() = hp_to_mm(effective_horizontal_pitch());
function panel_height_mm() = u_to_mm(effective_vertical_units());
function edge_inset_mm() = max(antenna_edge_inset, 0);
function isogrid_inset_mm() = RACK_RAIL_HEIGHT + antenna_rail_buffer;
function isogrid_width_mm() = panel_width_mm() - 2 * isogrid_inset_mm();
function isogrid_height_mm() = panel_height_mm() - 2 * isogrid_inset_mm();
function antenna_pad_diameter_mm() = antenna_hole_diameter + 2 * isogrid_antenna_buffer;
function antenna_row_length() = rotate_sdr() ? panel_height_mm() : panel_width_mm();
function antenna_spacing() = effective_antenna_count() > 1
	? max((antenna_row_length() - 2 * edge_inset_mm()) / (effective_antenna_count() - 1), 0)
	: 0;
function antenna_row_center_x() = rotate_sdr()
	? panel_width_mm() / 2 - antenna_edge_offset_mm()
	: 0;
function antenna_row_center_y() = rotate_sdr()
	? 0
	: effective_vertical_units() < 1
		? compact_antenna_offset_mm()
		: panel_height_mm() / 2 - antenna_edge_offset_mm();
function kerberos_top_mount_depth_mm() = 5;
function effective_kerberos_recess_depth_mm() = min(
	kerberos_mount_recess_depth,
	max(panel_depth - 0.5, 0)
);
function antenna_x(i) =
	(i - (effective_antenna_count() - 1) / 2) * antenna_spacing();

module at_antenna_centers() {
	translate([antenna_row_center_x(), antenna_row_center_y()])
		rotate(rotate_sdr() ? 90 : 0)
			for (i = [0:effective_antenna_count()-1]) {
				translate([antenna_x(i), 0])
					children();
			}
}

module antenna_holes_2d() {
	at_antenna_centers()
		circle(d=antenna_hole_diameter, $fn=48);
}

module antenna_mount_pads_2d() {
	at_antenna_centers()
		circle(d=antenna_pad_diameter_mm(), $fn=48);
}

// KerberosSDR coordinates are measured from its antenna-side edge:
// left/right are inset 5/10 mm; top holes are 5 mm deep; bottom-left and
// bottom-right are respectively 15/5 mm from the opposite edge.
module at_kerberos_mount_centers() {
	if (sdr_module == "KerberosSDR") {
		left_x = -sdr_width_mm() / 2 + 5;
		right_x = sdr_width_mm() / 2 - 10;
		mounts = [
			[left_x, kerberos_top_mount_depth_mm()],
			[right_x, kerberos_top_mount_depth_mm()],
			[left_x, sdr_height_mm() - 15],
			[right_x, sdr_height_mm() - 5]
		];

		for (mount = mounts) {
			translate(rotate_sdr()
				? [
					antenna_row_center_x()
						- antenna_center_to_device_edge_mm() - mount[1],
					mount[0]
				]
				: [
					mount[0],
					antenna_row_center_y()
						- antenna_center_to_device_edge_mm() - mount[1]
				])
				children();
		}
	}
}

module kerberos_mount_holes_2d() {
	at_kerberos_mount_centers()
		circle(d=kerberos_mount_hole_diameter, $fn=32);
}

module kerberos_mount_pads_2d() {
	at_kerberos_mount_centers()
		circle(d=kerberos_mount_pad_diameter, $fn=48);
}

module kerberos_mount_recesses_3d() {
	at_kerberos_mount_centers()
		translate([0, 0, panel_depth - effective_kerberos_recess_depth_mm()])
			cylinder(
				d=kerberos_mount_recess_diameter,
				h=effective_kerberos_recess_depth_mm() + epsilon,
				$fn=48
			);
}

module sdr_isogrid_panel_2d() {
	assert(
		isogrid_width_mm() > 0 && isogrid_height_mm() > 0,
		"Rail inset must leave a positive IsoGrid area."
	);

	intersection() {
		makerpanel_2d(effective_horizontal_pitch(), effective_vertical_units());
		union() {
			difference() {
				square([panel_width_mm(), panel_height_mm()], center=true);
				square([isogrid_width_mm(), isogrid_height_mm()], center=true);
			}
			difference() {
				isogrid_rect(
					isogrid_width_mm(),
					isogrid_height_mm(),
					triangle_size=isogrid_triangle_size,
					thickness=isogrid_rib_thickness
				);
				union() {
					antenna_mount_pads_2d();
					kerberos_mount_pads_2d();
				}
			}
			antenna_mount_pads_2d();
			kerberos_mount_pads_2d();
		}
	}
}

module antenna_maker_panel_2d() {
	difference() {
		if (sdr_enabled()) {
			sdr_isogrid_panel_2d();
		} else {
			makerpanel_2d(effective_horizontal_pitch(), effective_vertical_units());
		}
		union() {
			antenna_holes_2d();
			kerberos_mount_holes_2d();
		}
	}
}

module antenna_maker_panel() {
	difference() {
		linear_extrude(height=panel_depth)
			antenna_maker_panel_2d();
		kerberos_mount_recesses_3d();
	}
}

if (part == "assembly") {
	antenna_maker_panel();
} else if (part == "panel") {
	antenna_maker_panel();
} else if (part == "panel_2d") {
	antenna_maker_panel_2d();
}


