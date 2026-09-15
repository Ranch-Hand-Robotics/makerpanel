// MakerPanel design for Elgato Stream Deck OEM Modules.
// Rear-loading sleeve with a separate, panel-bolted rear retainer.
// Laser-cut versions are intentionally not supported.

// Reference: https://www.elgato.com/us/en/p/stream-deck-module-32-keys
// All rectangular device envelopes and bezel overlaps are provisional.
// The supplied 32-key DXF is retained as a reference, not used for this fit:
// its extents differ from the current envelope. Measure before fabrication.
include <makerpanel/common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, makerpanel, bottom]
verticalUnits = 2.5; // [2:0.5:8] Panel height (U); adds 0.5U flange margin
horizontalPitch = 43; // [16:1:80] Panel width (HP); adds 4HP flange margin
tilt_angle = 15; // [0:1:25] positive raises the +Y edge
module_type = "15_key"; // [6_key, 15_key, 32_key]

/* [Hidden] */
module hidden() {}
panel_depth = 3; // mm
tray_wall = 3; // mm
front_lip_depth = 3; // mm along the device axis
module_clearance = 0.6; // mm per side
retention_lip = 2.5; // mm overlap onto device front perimeter
rear_plate_depth = 3; // mm along the device axis
rear_support_width = 6; // mm rear bearing rim around the cable opening
rear_seat_clearance = 0.2; // mm axial play; adjust for a thin compliant pad
rear_seat_recess = 3; // mm forward into the sleeve; bottom retainer only
rear_insert_clearance = 0.3; // mm per side where retainer enters the sleeve
rear_flange_width = 9; // mm beyond each side of the sleeve
rear_flange_depth = 3; // mm; flange mating face is always world Z=0
rear_bolt_diameter = 3.2; // mm; four M3 through-bolts, not device screws
rear_bolt_end_inset = 12; // mm from each end of a side flange
// Measured approximately on the 15-key device; local device axes in mm.
rear_tab_length = 5; // along each left/right edge (Y)
rear_tab_width = 2; // inward from the device outer surface (X)
rear_tab_drop = 5; // behind the device rear face (-Z)
rear_tab_end_inset = 10; // tab centers from the top/bottom device edges
rear_tab_clearance = 0.3; // axial clearance at each end of the tab relief
rear_tab_side_clearance = 2; // generous X/Y clearance on each tab face
epsilon = 0.01;

// Provisional device dimensions; no scale is inferred from the reference DXF.
function module_width_mm(kind) =
	kind == "6_key" ? 72 :
	kind == "15_key" ? 108 :
	170;

function module_height_mm(kind) =
	kind == "6_key" ? 52 :
	kind == "15_key" ? 71 :
	103;

function module_depth_mm(kind) =
	kind == "6_key" ? 11 :
	kind == "15_key" ? 13 :
	13;

function module_width() = module_width_mm(module_type);
function module_height() = module_height_mm(module_type);
function module_depth() = module_depth_mm(module_type);
function streamdeck_bore_width() = module_width() + 2*module_clearance;
function streamdeck_bore_height() = module_height() + 2*module_clearance;
function streamdeck_outer_width() = streamdeck_bore_width() + 2*tray_wall;
function streamdeck_outer_height() = streamdeck_bore_height() + 2*tray_wall;

// Device front seats at local Z=0, rear at local Z=-module_depth().
// Raise the tilted seat so its lowest outer edge reaches the panel underside.
// At zero tilt the seat and the rear flange mating faces are all world Z=0.
function streamdeck_seat_z() =
	streamdeck_outer_height()/2 * sin(tilt_angle);
// Intersection of the straight, tilted sleeve with the flat panel plane.
function streamdeck_foot_y() = streamdeck_seat_z() * tan(tilt_angle);
function streamdeck_foot_depth() =
	streamdeck_outer_height() / cos(tilt_angle);
function minimum_horizontal_pitch() =
	// Reserve side flanges plus a separate rail-mounting strip on each side.
	ceil((streamdeck_outer_width() + 2*rear_flange_width
		+ 2*RACK_RAIL_HEIGHT) / HP);
function minimum_vertical_units() =
	// Include the shifted sleeve footprint; round up in half-U increments.
	ceil(4*(abs(streamdeck_foot_y()) + streamdeck_foot_depth()/2
		+ RACK_RAIL_HEIGHT) / U) / 2;
function effective_horizontal_pitch() =
	max(horizontalPitch, minimum_horizontal_pitch());
function effective_vertical_units() =
	max(verticalUnits, minimum_vertical_units());
// Finite working bound for cutters and clipping planes, not a fit dimension.
function streamdeck_cut_span() =
	hp_to_mm(effective_horizontal_pitch())
	+ u_to_mm(effective_vertical_units())
	+ module_depth() + streamdeck_seat_z() + rear_plate_depth;
function streamdeck_rear_seat_z() =
	-module_depth() - rear_seat_clearance + rear_seat_recess;
function streamdeck_bolt_x() =
	streamdeck_outer_width()/2 + rear_flange_width/2;
function streamdeck_bolt_y_offset() =
	streamdeck_foot_depth()/2 - rear_bolt_end_inset;

module streamdeck_placement() {
	translate([0, 0, streamdeck_seat_z()])
		rotate([tilt_angle, 0, 0]) children();
}

module streamdeck_32_cutout_2d() {
	// DXF extents: X=-176.256..165.743, Y=-95.036..75.018 mm.
	// Center explicitly because some renderers ignore import(center=true).
	translate([5.2565, 10.0088])
		import("32_cutout.dxf");
}

module streamdeck_module_cutout_2d() {
	if (module_type == "32_key") {
		streamdeck_32_cutout_2d();
	} else {
		square([
			module_width_mm(module_type) + 2*module_clearance,
			module_height_mm(module_type) + 2*module_clearance
		], center=true);
	}
}

module streamdeck_device_clearance_3d() {
	// Full device envelope slides in from local -Z up to the front stop.
	// No rear floor or smaller rear opening may obstruct this path.
	span = streamdeck_cut_span();
	union() {
		translate([0, 0, -span/2])
			cube([
				streamdeck_bore_width(),
				streamdeck_bore_height(),
				span
			], center=true);

		// Smaller front aperture leaves a lip bearing on the device bezel.
		cube([
			module_width() - 2*retention_lip,
			module_height() - 2*retention_lip,
			2*span
		], center=true);
	}
}

module streamdeck_rear_bolt_holes() {
	// One shared pattern for the panel and the removable retainer flanges.
	// Bolts are normal to the MakerPanel regardless of the device tilt.
	for (side = [-1, 1], end = [-1, 1])
		translate([side*streamdeck_bolt_x(),
			streamdeck_foot_y() + end*streamdeck_bolt_y_offset(), 0])
			cylinder(d=rear_bolt_diameter,
				h=2*streamdeck_cut_span(), center=true, $fn=32);
}

// Preserve the standard rail-hole profile through any added host geometry.
// These bores stay normal to the flat panel, not the tilted device.
module streamdeck_panel_mount_subtractions() {
	linear_extrude(height=2*streamdeck_cut_span(), center=true)
		difference() {
			square([
				hp_to_mm(effective_horizontal_pitch()),
				u_to_mm(effective_vertical_units())
			], center=true);
			makerpanel_2d(
				effective_horizontal_pitch(),
				effective_vertical_units()
			);
		}
}

module streamdeck_device_subtractions() {
	streamdeck_placement() streamdeck_device_clearance_3d();
}

// Front/host cuts only. Do not apply these to the removable rear retainer.
// Keep cuts outside union()/hull() so joined material cannot refill them.
module streamdeck_subtractions() {
	union() {
		streamdeck_device_subtractions();
		streamdeck_panel_mount_subtractions();
		streamdeck_rear_bolt_holes();
	}
}

// Apply the Stream Deck volumes to any number of positive child objects.
// Openings span the current assembly; larger host shells need longer cutters.
module streamdeck_subtract() {
	difference() {
		union() {
			children();
		}
		streamdeck_subtractions();
	}
}

module streamdeck_box_solid() {
	// Straight sleeve along the slide axis, trimmed at the panel underside.
	// Unlike a hull to an untilted foot, this cannot pinch the loading bore.
	span = streamdeck_cut_span();
	intersection() {
		streamdeck_placement()
			translate([0, 0, (front_lip_depth - span)/2])
				cube([streamdeck_outer_width(),
					streamdeck_outer_height(), span + front_lip_depth],
					center=true);
		translate([-span, -span, 0]) cube([2*span, 2*span, span]);
	}
}

module streamdeck_panel_solid() {
	// Standard MakerPanel body provides the actual rail mounting interface.
	// Rail mounting holes are supplied by makerpanel(), not device cutters.
	makerpanel(
		effective_horizontal_pitch(),
		effective_vertical_units(),
		thickness=panel_depth,
		chamfer_start=1.2
	);
}

module streamdeck_solids() {
	union() {
		streamdeck_panel_solid();
		streamdeck_box_solid();
	}
}

module streamdeck_panel() {
	streamdeck_subtract() {
		streamdeck_solids();
		children();
	}
}

module streamdeck_rear_flange_solids() {
	for (side = [-1, 1])
		translate([side*streamdeck_bolt_x(), streamdeck_foot_y(),
			-rear_flange_depth/2])
			cube([rear_flange_width + epsilon, streamdeck_foot_depth(),
				rear_flange_depth], center=true);
}

module streamdeck_rear_solid() {
	span = streamdeck_cut_span();
	union() {
		intersection() {
			// Angled back plate connected to a flat mating rim at world Z=0.
			hull() {
				streamdeck_placement()
					translate([0, 0, streamdeck_rear_seat_z()
						- rear_plate_depth/2])
						cube([streamdeck_outer_width(),
							streamdeck_outer_height(), rear_plate_depth],
							center=true);
				translate([0, streamdeck_foot_y(), -rear_flange_depth/2])
					cube([streamdeck_outer_width(), streamdeck_foot_depth(),
						rear_flange_depth], center=true);
			}
			union() {
				// The main cup stays behind the flat MakerPanel.
				translate([-span, -span, -span])
					cube([2*span, 2*span, span]);
				// The raised portion of the angled seat fits INSIDE the bore.
				// Clearance prevents collision with the fixed front sleeve.
				streamdeck_placement()
					cube([
						streamdeck_bore_width() - 2*rear_insert_clearance,
						streamdeck_bore_height() - 2*rear_insert_clearance,
						2*span
					], center=true);
			}
		}
		streamdeck_rear_flange_solids();
	}
}

// Four metal tabs: two on each side, flush with the device outer edges.
// Caller supplies streamdeck_placement(); never cut the front/host panel.
module streamdeck_rear_tab_clearance() {
	if (module_type == "15_key")
		for (side = [-1, 1], end = [-1, 1])
			translate([
				side*(module_width()/2 - rear_tab_width/2),
				end*(module_height()/2 - rear_tab_end_inset),
				// Keep the old rear extent and open through the recessed seat.
				-module_depth() + (rear_seat_recess - rear_tab_drop)/2
			])
				cube([
					rear_tab_width + 2*rear_tab_side_clearance,
					rear_tab_length + 2*rear_tab_side_clearance,
					rear_tab_drop + rear_seat_recess + 2*rear_tab_clearance
				], center=true);
}

module streamdeck_rear_subtractions() {
	span = streamdeck_cut_span();
	streamdeck_placement() {
		streamdeck_rear_tab_clearance();
		// Angled seating inset: leave a back plate at the device rear face.
		translate([0, 0, (streamdeck_rear_seat_z() + span)/2])
			cube([streamdeck_bore_width(), streamdeck_bore_height(),
				span - streamdeck_rear_seat_z()], center=true);
		// Cable/vent access retains a perimeter that traps the device.
		cube([module_width() - 2*rear_support_width,
			module_height() - 2*rear_support_width, 2*span], center=true);
	}
	streamdeck_rear_bolt_holes();
}

module streamdeck_rear() {
	difference() {
		streamdeck_rear_solid();
		streamdeck_rear_subtractions();
	}
}

// Attach future host geometry to the fixed front, never to the rear retainer:
// streamdeck_panel() my_hull(); or streamdeck_assembly() my_hull();
// Keep the world-Z<0 loading corridor clear; cutters open that corridor.
module streamdeck_assembly() {
	color("LightSlateGray") streamdeck_panel() children();
	color("DarkOrange") streamdeck_rear();
}

assert(tilt_angle >= 0 && tilt_angle <= 25,
	"Rear-loading mount supports tilt angles from 0 to 25 degrees.");
assert(min(module_width(), module_height()) >
	2*max(retention_lip, rear_support_width), "Invalid retaining rim width.");
assert(rear_insert_clearance > 0 &&
	rear_insert_clearance < module_clearance + rear_support_width,
	"Rear insert needs clearance and a remaining support rim.");

if (part == "assembly") {
	streamdeck_assembly();
} else if (part == "makerpanel") {
	streamdeck_panel();
} else if (part == "bottom") {
	streamdeck_rear();
}
