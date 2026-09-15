// MakerPanel for an underside-mounted meishi trackball module.
// Reference: https://github.com/aki27kbd/trackball_module
// Dimensions extracted from meishi_trackball_module_bottom.pdf at 1:1.
// See README.md for the measurement method and mounting assumptions.

include <../../makerpanel/panel.scad>

/* [Customization] */
part = "makerpanel"; // [makerpanel, panel_2d, assembly, footprint]
horizontalPitch = 18; // [12:1:40]
verticalUnits = 4; // [2.5:0.5:6]
panelThickness = 3; // [1.6:0.1:3]
// Added to the PDF hole diameter; zero preserves the original pattern.
holeClearance = 0; // [0:0.05:1]
// Cutout width is independent of the horizontal bolt spacing.
openingWidth = 54; // [1:0.1:80]
// Top/bottom opening edges are inset from the bolt-row centerlines.
openingInset = 3; // [0:0.1:20]
// Move the cutout and module bolts together toward the panel top (+Y).
trackballOffsetY = 20; // [-40:0.5:40]

/* [Hidden] */
// Native PDF units are points: 1 pt = 25.4 / 72 mm.
// Origin: outline center. X right, Y up (PDF page Y is inverted).
trackball_width = 55;
trackball_height = 91;
trackball_corner_radius = 2.1;
trackball_hole_diameter = 2.2;
trackball_hole_pitch = [50.8, 86.8];
trackball_hole_centers = [
	[-trackball_hole_pitch.x / 2, -trackball_hole_pitch.y / 2],
	[ trackball_hole_pitch.x / 2, -trackball_hole_pitch.y / 2],
	[-trackball_hole_pitch.x / 2,  trackball_hole_pitch.y / 2],
	[ trackball_hole_pitch.x / 2,  trackball_hole_pitch.y / 2]
];
panel_width = hp_to_mm(horizontalPitch);
// Preserve the library's full-U height, not the spec's 128.5 mm 3U face.
panel_height = u_to_mm(verticalUnits);
mount_diameter = trackball_hole_diameter + holeClearance;
opening_size = [openingWidth, trackball_hole_pitch.y - 2 * openingInset];
trackball_offset = [0, trackballOffsetY];
edge_clearance = 2;
rail_hole_x = (panel_width - RACK_RAIL_HEIGHT) / 2;
rail_hole_y = (panel_height - RACK_RAIL_HEIGHT) / 2;
footprint_preview_thickness = 0.5;
$fn = 64;

module validate_trackball_panel() {
	assert(horizontalPitch > 0 && horizontalPitch == floor(horizontalPitch),
		"Panel width must be a positive whole number of HP.");
	assert(verticalUnits > 0 && panelThickness > 0 && panelThickness <= 3,
		"Use a positive panel height and a thickness up to 3 mm.");
	assert(holeClearance >= 0, "Hole clearance must not be negative.");
	assert(opening_size.x > 0 && opening_size.y > 0,
		"Opening inset must leave a positive rectangular opening.");
	assert(openingInset > mount_diameter / 2,
		"Opening must leave material inside the top/bottom bolt-hole edges.");
	assert(panel_width >= trackball_width + 2 * edge_clearance &&
		   panel_height >= trackball_height + 2 * edge_clearance +
		   2 * abs(trackballOffsetY),
		"Panel must leave 2 mm around the trackball footprint.");
	assert(panel_width >= trackball_hole_pitch.x + mount_diameter +
		   2 * edge_clearance &&
		   panel_height >= trackball_hole_pitch.y + mount_diameter +
		   2 * edge_clearance + 2 * abs(trackballOffsetY),
		"Trackball mounting holes need 2 mm of material to the panel edge.");
	// Keep rail holes and an extra 2 mm clear of the module footprint.
	assert(rail_hole_x >= trackball_width / 2 +
		   MOUNT_HOLE_DIAMETER / 2 + edge_clearance ||
		   rail_hole_y >= trackball_height / 2 + abs(trackballOffsetY) +
		   MOUNT_HOLE_DIAMETER / 2 + edge_clearance,
		"Increase HP or U: the module would obstruct the rail fasteners.");
	for (hole = trackball_hole_centers)
		for (sx = [-1, 1], sy = [-1, 1])
			assert(norm(hole + trackball_offset -
				   [sx * rail_hole_x, sy * rail_hole_y]) >=
				   (mount_diameter + MOUNT_HOLE_DIAMETER) / 2 +
				   edge_clearance,
				"Trackball and rail holes need 2 mm of material between.");
	children();
}

module trackball_mount_holes_2d(diameter = mount_diameter) {
	for (hole = trackball_hole_centers)
		translate(hole)
			circle(d = diameter);
}

module trackball_outline_2d() {
	// Idealized rounded rectangle from the PDF's straight-line endpoints.
	offset(r = trackball_corner_radius)
		square([
			trackball_width - 2 * trackball_corner_radius,
			trackball_height - 2 * trackball_corner_radius
		], center = true);
}

module trackball_footprint_2d() {
	difference() {
		trackball_outline_2d();
		trackball_mount_holes_2d(diameter = trackball_hole_diameter);
	}
}

module trackball_panel_2d() {
	validate_trackball_panel()
		difference() {
			makerpanel_2d(horizontalPitch, verticalUnits);
			translate(trackball_offset) {
				trackball_mount_holes_2d();
				square(opening_size, center = true);
			}
		}
}

module trackball_panel() {
	linear_extrude(height = panelThickness)
		trackball_panel_2d();
}

module trackball_assembly() {
	trackball_panel();
	// A footprint only, NOT a model of the module's unknown height.
	// Background geometry is excluded from manufacturing exports.
	%translate([0, trackballOffsetY, -footprint_preview_thickness])
		linear_extrude(height = footprint_preview_thickness)
			trackball_footprint_2d();
}

if (part == "makerpanel") {
	trackball_panel();
} else if (part == "panel_2d") {
	trackball_panel_2d();
} else if (part == "assembly") {
	trackball_assembly();
} else if (part == "footprint") {
	trackball_footprint_2d();
} else {
	assert(false, str("Unknown part: ", part));
}


