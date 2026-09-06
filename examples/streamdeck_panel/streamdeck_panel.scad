// MakerPanel design for Elgato Stream Deck OEM Modules.
// This is a 3D-printed, front drop-in tray with rear screw retention.
// Laser-cut versions are intentionally not supported.

// Reference: https://www.elgato.com/us/en/p/stream-deck-module-32-keys
// The 32-key DXF supplies the module opening and its rear mounting holes.
// The 6-key and 15-key envelopes below are provisional until their CAD files
// are added; replace those values with measured dimensions before fabrication.
include <makerpanel/common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, panel, box, solids, subtractions]
verticalUnits = 3.5; // [2:0.5:8] Panel height (U); adds 0.5U flange margin
horizontalPitch = 43; // [16:1:80] Panel width (HP); adds 4HP flange margin
tilt_angle = 15; // [0:1:25] box tilt about X; positive raises the +Y edge
module_type = "32_key"; // [6_key, 15_key, 32_key]

/* [Hidden] */
module hidden() {}
panel_depth = 3; // mm
tray_wall = 3; // mm
tray_floor = 3; // mm
tray_recess_depth = 0; // mm; recess is deferred until the box is validated
module_clearance = 0.6; // mm per side
retention_lip = 2.5; // mm
rear_screw_diameter = 3.2; // mm
rear_screw_head_diameter = 6.5; // mm
rear_screw_head_depth = 2.2; // mm
rear_mount_x_spacing = 250; // mm, provisional 32-key rear-hole spacing
rear_mount_y_from_back = 18; // mm, provisional rear-hole inset
epsilon = 0.01;

// Provisional envelope dimensions, measured/derived in the same XY plane as
// the 32-key DXF. The 32-key opening remains the authoritative profile.
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
function minimum_horizontal_pitch() =
	// Reserve one full MakerRail width on each side of the device.
	ceil((module_width() + 2*RACK_RAIL_HEIGHT + 2*module_clearance) / HP);
function minimum_vertical_units() =
	ceil((module_height() + 2*module_clearance) / U);
function effective_horizontal_pitch() =
	max(horizontalPitch, minimum_horizontal_pitch());
function effective_vertical_units() =
	max(verticalUnits, minimum_vertical_units());
// Device clearances are defined in box-local coordinates before tilting.
function tray_origin_z() = tray_recess_depth;

// Bounds of the flat panel and box in the tilted box's coordinate frame.
// Extend openings through the hull without moving the retention ledge.
function streamdeck_local_min_z() = min(
	-(module_depth() + tray_floor)/2,
	-u_to_mm(effective_vertical_units())/2 * abs(sin(tilt_angle))
);
function streamdeck_local_max_z() = max(
	(module_depth() + tray_floor)/2,
	u_to_mm(effective_vertical_units())/2 * abs(sin(tilt_angle))
		+ panel_depth * cos(tilt_angle)
);
function streamdeck_hull_z_extent() = max(
	panel_depth,
	(module_height() + 2*tray_wall)/2 * abs(sin(tilt_angle))
		+ (module_depth() + tray_floor)/2 * abs(cos(tilt_angle))
) + epsilon;

module streamdeck_placement() {
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
	// Keep the existing seating levels, extending only the open ends.
	device_bottom = tray_origin_z() + tray_floor
		- module_depth()/2 - epsilon;
	device_top = max(
		tray_origin_z() + tray_floor + 1.5*module_depth() + epsilon,
		streamdeck_local_max_z() + epsilon
	);
	rear_top = -tray_origin_z() - 2*tray_floor
		+ module_depth()/2 + epsilon;
	rear_bottom = min(
		-tray_origin_z() - 2*tray_floor - module_depth()/2 - epsilon,
		streamdeck_local_min_z() - epsilon
	);
	union() {
		translate([0, 0, (device_bottom + device_top)/2])
			cube([
				module_width() + 2*module_clearance,
				module_height() + 2*module_clearance,
				device_top - device_bottom
			], center=true);

		// Blast the smaller rear/bottom opening through the box floor. Its
		// 10 mm inset leaves a continuous perimeter for structural support.
		translate([
			0,
			0,
			(rear_bottom + rear_top)/2
		])
			cube([
				module_width() + 2*tray_wall - 20,
				module_height() + 2*tray_wall - 20,
				rear_top - rear_bottom
			], center=true);
	}
}

module rear_screw_holes_local() {
	// Screws enter from the underside of the MakerPanel, through the tray
	// floor, and into the module's rear mounting holes.
	for (x = [-1, 1])
		translate([
			x * rear_mount_x_spacing/2,
			module_height()/2 - rear_mount_y_from_back,
			-epsilon
		]) {
				cylinder(
				d=rear_screw_diameter,
				h=tray_floor + 2*epsilon,
				$fn=32
			);
			translate([0, 0, -epsilon])
				cylinder(
					d=rear_screw_head_diameter,
					h=rear_screw_head_depth,
					$fn=32
				);
		}
}

// Recover the standard rail-hole profile after hull() fills all holes.
// These bores stay normal to the flat panel, not the tilted device.
module streamdeck_panel_mount_subtractions() {
	linear_extrude(height=2*streamdeck_hull_z_extent(), center=true)
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
	streamdeck_placement() {
		streamdeck_device_clearance_3d();
		rear_screw_holes_local();
	}
}

// Panel underside Z=0, panel top Z=panel_depth; box pivots at its center.
// Keep cuts outside union()/hull() so joined material cannot refill them.
module streamdeck_subtractions() {
	union() {
		streamdeck_device_subtractions();
		streamdeck_panel_mount_subtractions();
	}
}

// Apply the Stream Deck volumes to any number of positive child objects.
// Openings span this panel/box hull; deeper child shells need longer cutters.
module streamdeck_subtract() {
	difference() {
		union() {
			children();
		}
		streamdeck_subtractions();
	}
}

module streamdeck_box_solid() {
	streamdeck_placement()
		cube([
			module_width() + 2*tray_wall,
			module_height() + 2*tray_wall,
			module_depth() + tray_floor
		], center=true);
}

module streamdeck_panel_solid() {
	// Standard MakerPanel body provides the actual rail mounting interface.
	// Rail mounting holes are supplied by makerpanel(), not device cutters.
	makerpanel(
		effective_horizontal_pitch(),
		effective_vertical_units(),
		thickness=panel_depth
	);
}

module streamdeck_mount_solid() {
	// Bridge only the box footprint to the panel plane. Hulling the entire
	// MakerPanel would bury its flat mounting flange inside the sloped body.
	hull() {
		translate([0, 0, panel_depth/2])
			cube([
				module_width() + 2*tray_wall,
				module_height() + 2*tray_wall,
				panel_depth
			], center=true);
		streamdeck_box_solid();
	}
}

module streamdeck_solids() {
	union() {
		streamdeck_panel_solid();
		streamdeck_mount_solid();
	}
}

module streamdeck_box() {
	difference() {
		streamdeck_box_solid();
		streamdeck_device_subtractions();
	}
}

module streamdeck_panel() {
	streamdeck_subtract() {
		streamdeck_solids();
		children();
	}
}

// Supply a future hull as a child: streamdeck_assembly() my_hull();
// For custom unions or hull() operations, pass positive geometry to
// streamdeck_subtract(), or subtract streamdeck_subtractions() explicitly.
// Apply the same placement transform to solids and cutters together.
module streamdeck_assembly() {
	streamdeck_panel() children();
}

if (part == "assembly") {
	streamdeck_assembly();
} else if (part == "box") {
	streamdeck_box();
} else if (part == "solids") {
	streamdeck_solids();
} else if (part == "subtractions") {
	streamdeck_subtractions();
} else if (part == "panel") {
		makerpanel_2d(
			effective_horizontal_pitch(),
			effective_vertical_units()
		);
}
