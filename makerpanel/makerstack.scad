// MakerStack: stackable MakerRail host prototype. Units: mm.
// Documentation: ../docs/makerstack.md
// Top-down joints are a fit-test concept, NOT a load-rated connector.
// Printed rails and supports are one part; X runs continue through corners.
// Optional bonded metal shares the slotted outline, above printed backing.
// Columns belong to the upper printed support; screws clamp the lower rail.
// No bracing is modeled yet; qualify stiffness before carrying equipment.

include <common.scad>
use <rails.scad>
use <panel.scad>

/* [View] */
part = "assembly"; // [assembly,exploded,frame,base,support,top,joint,section]
panels = "top"; // [none, top, all]
explode_gap = 12; // [6:1:30]
show_hardware = true;
// Display-only driver envelope in the joint cutaway.
show_driver = true;
// For part="support": lowest support has integrated mounting feet.
base_support = false;

/* [Stack] */
// X distance between the side-rail centerlines.
frame_width_hp = 48; // [24:1:96]
// Matches panel.scad: panel outer height, not rail center spacing.
panel_height_u = 3; // [2:1:6]
layers = 2; // [1:1:5]
// Corresponding panel seating planes; NOT guaranteed equipment clearance.
layer_pitch_u = 1; // [1:0.5:3]

/* [Rail reinforcement] */
// Optional bonded top sheet; zero gives a fully printed slotted rail.
rail_metal_thickness = 0; // [0, 1, 1.5, 2]

/* [Under-rail nut channel] */
// Rounded U-profile adapted from Nomad's t_slot_channel_profile_2d().
// Width/depth/radius describe the cavity, not a guaranteed hardware fit.
nut_channel_width = 11;
nut_channel_depth = 7;
nut_channel_radius = 5;
// Material on each side of the channel; cap and support grow together.
nut_channel_wall = 2;
// Lowest tier only: open underside between localized foot/nut saddles.
base_open_channels = true;

/* [Top-down column joint - prototype dimensions] */
frame_depth = 15;
column_width = 14;
column_depth = 14;
// Hollow shaft accepts the screw head and a slender long driver.
access_diameter = 6.2;
screw_clearance = 3.4;
screw_seat = 3;
key_width = 10;
key_length = 1.5;
// Per-side clearance of the locating tab in the corner slot opening.
fit_clearance = 0.25;

/* [Hardware envelopes - select and test matching parts] */
screw_diameter = 3;
screw_head_diameter = 5.5;
screw_head_height = 3;
screw_length = 12;
// Locked nut: short side along rail, long side spanning the slot.
nut_length = 5;
nut_width = 8;
nut_thickness = 2;
// Rotate beside the guide, then slide in; its sides resist nut rotation.
nut_guide_length = 8;
driver_diameter = 4;
driver_reach = 60;

/* [Base feet] */
foot_style = "screw"; // [screw, bond]
foot_width = 32;
foot_thickness = 4;
// Base surface to underside of the lowest frame's support ring.
foot_seat_height = 10;
foot_hole_diameter = 4.5;
foot_hole_spacing = 22;
// Base screw heads must also pass through the 6.9 mm rail opening.
foot_access_diameter = 6.5;

/* [Preview panel] */
// Default 16HP panel holes clear the default 48HP rail's slots.
// Recheck slot/rib alignment when changing either width.
preview_panel_hp = 16;

/* [Hidden] */
$fn = 48;
cut_epsilon = 0.02;
rail_width = RACK_RAIL_HEIGHT;
// Total finished rail thickness; retain at least 2 mm printed backing.
rail_thickness = makerstack_rail_total_t(RACK_RAIL_THICKNESS,
	rail_metal_thickness);
frame_width = hp_to_mm(frame_width_hp);
panel_height = u_to_mm(panel_height_u);
rail_spacing = panel_height - rail_width;
layer_pitch = u_to_mm(layer_pitch_u);
layer_count = max(1, floor(layers));
column_height = layer_pitch - frame_depth;
base_plane_z = foot_seat_height + frame_depth;
channel_support_width = nut_channel_width + 2 * nut_channel_wall;
key_depth = T_SLOT_HEIGHT - 2 * fit_clearance;
// Shared with case adapters: exact intersections of the rail centerlines.
post_x = makerstack_post_x(frame_width, rail_width);

// Joint constraints for sensible customization (not render-blocking checks):
// - column_depth <= channel_support_width to stay under the rail footprint.
// - layer_pitch > frame_depth + screw_seat + screw_head_height.
// - screw head < access_diameter < T_SLOT_HEIGHT; allow real fit tolerance.
// - key_length < rail_thickness; nut must insert, turn, and resist spinning.
// - frame_depth > rail_thickness + nut_channel_depth for a closed floor.
// - Foot screw/tool paths need a clear rail slot or unobstructed outer access.
// - Keep reserved post slots clear of panels, electronics, and panel nuts.

// Finished slotted rail thickness, including optional metal reinforcement.
// Callers pass this total as cap and the sheet thickness separately as metal.
function makerstack_rail_total_t(full_t = 3, metal_t = 0,
	printed_min_t = 2) =
	max(0, full_t, max(0, metal_t) + max(0, printed_min_t));

// Cross-section coordinates: X across the rail, Y downward from its back.
// Like Nomad: straight opening, rounded bottom corners, optional flat floor.
// A radius of width/2 gives a semicircular bottom if depth accommodates it.
function makerstack_nut_channel_profile(width = nut_channel_width,
	depth = nut_channel_depth, radius = nut_channel_radius) =
	let(
		w = width / 2,
		d = depth,
		r = min(max(0, radius), d, w),
		n = 12
	)
	r == 0 ? [[-w, 0], [w, 0], [w, -d], [-w, -d]] : concat(
		[[-w, 0], [w, 0]],
		[for (i = [0:1:n])
			[w - r + r * cos(-i * 90 / n),
				-d + r + r * sin(-i * 90 / n)]],
		[for (i = [0:1:n])
			[-w + r + r * cos(-90 - i * 90 / n),
				-d + r + r * sin(-90 - i * 90 / n)]]
	);

// X-aligned cavity with its opening exactly at the rail cap underside.
// No cutter enters the top rail, so its slots and retention lips stay intact.
module makerstack_nut_channel(length, width = nut_channel_width,
	depth = nut_channel_depth, radius = nut_channel_radius,
	cap = rail_thickness) {
	translate([-length / 2, 0, -cap])
		rotate([90, 0, 90])
			linear_extrude(length, convexity = 4)
				polygon(makerstack_nut_channel_profile(width, depth, radius));
}

// X pockets reach beyond corner axes, leaving a channel-wall end stop.
// Y pockets reach the slot ends, retaining the canonical end bridges.
// Nuts enter through the top slots. Column shafts open into these pockets.
module makerstack_nut_channels(frame = frame_width, spacing = rail_spacing,
	rail = rail_width, width = nut_channel_width, depth = nut_channel_depth,
	radius = nut_channel_radius, cap = rail_thickness) {
	for (sy = [-1, 1])
		translate([0, sy * spacing / 2, 0])
			makerstack_nut_channel(frame + width,
				width, depth, radius, cap);
	for (sx = [-1, 1])
		translate([sx * frame / 2, 0, 0])
			rotate([0, 0, 90])
				makerstack_nut_channel(spacing - rail - 2 * RACK_SUPPORT_WIDTH,
					width, depth, radius, cap);
}

// Open the underside, retaining finite saddles for post loads and loose nuts.
// These local connections do not close the full rail run with a bottom web.
module makerstack_bottom_openings(frame, spacing, rail, width, depth, cap,
	saddle_width = 14, saddle_depth = 14) {
	difference() {
		makerstack_nut_channels(frame, spacing, rail, width,
			depth - cap + 0.02, 0, cap);
		makerstack_posts(makerstack_post_x(frame, rail), spacing)
			translate([0, 0, -depth / 2])
				cube([saddle_width, saddle_depth, depth + 0.04], center = true);
	}
}

// Local narrowing leaves an axial slide-in path at both ends of the guide.
// Excluded from channel cutters, these walls join the ring sides and floor.
module makerstack_nut_guides(frame = frame_width, spacing = rail_spacing,
	support = channel_support_width, depth = frame_depth, nut = nut_width,
	clearance = fit_clearance, length = nut_guide_length,
	cap = rail_thickness, rail = rail_width) {
	gap = nut + 2 * clearance;
	wall = (support - gap) / 2;
	makerstack_posts(makerstack_post_x(frame, rail), spacing)
		for (sy = [-1, 1])
			translate([-length / 2,
				sy > 0 ? gap / 2 : -support / 2, -depth])
				cube([length, wall, depth - cap]);
}

// Keep the rail argument for callers; joint axes no longer depend on slots.
function makerstack_post_x(frame, rail = 11) = frame / 2;

// Four axes at the exact intersections of the rail centerlines.
// Columns consume rail footprint, not the central equipment opening.
module makerstack_posts(x = post_x, spacing = rail_spacing) {
	for (sx = [-1, 1], sy = [-1, 1])
		translate([sx * x, sy * spacing / 2, 0])
			children();
}

// Tab enters the LOWER rail slot; the shoulder carries compression.
// This is a locator, not a snap lock or a load-rated anti-racking joint.
module makerstack_key(size = [key_width, key_depth, key_length]) {
	translate([-size[0] / 2, -size[1] / 2, 0]) cube(size);
}

// Shared centered frame outline. Width changes never move rail centerlines.
module makerstack_ring_2d(width, frame = frame_width, spacing = rail_spacing) {
	difference() {
		square([frame + width, spacing + width], center = true);
		square([frame - width, spacing - width], center = true);
	}
}

// Canonical strips define only the mounting interface, not the wider cap.
// Full-length X rails own the corners. Y rails butt into their inner sides.
module makerstack_canonical_rails_2d(frame = frame_width,
	spacing = rail_spacing, rail = rail_width) {
	for (sy = [-1, 1])
		translate([-(frame + rail) / 2, sy * spacing / 2])
			maker_rail_2d(frame + rail, rail, mounting_holes = false);
	for (sx = [-1, 1])
		translate([sx * frame / 2, 0]) rotate(90) {
			// Butt to the X rails with canonical 3 mm end bridges.
			length = spacing - rail;
			translate([-length / 2, 0])
				maker_rail_2d(length, rail, mounting_holes = false);
		}
}

// Preserve ordinary slots; extend only the four end slots over column axes.
// Do not widen maker_rail_2d() itself: that also changes end offsets/slots.
module makerstack_top_2d(frame = frame_width, spacing = rail_spacing,
	support = channel_support_width, rail = rail_width,
	joint_width = key_width + 2 * fit_clearance) {
	difference() {
		makerstack_ring_2d(support, frame, spacing);
		difference() {
			makerstack_ring_2d(rail, frame, spacing);
			makerstack_canonical_rails_2d(frame, spacing, rail);
		}
		makerstack_posts(makerstack_post_x(frame, rail), spacing)
			square([joint_width, T_SLOT_HEIGHT], center = true);
	}
}

// Printed slotted rail, support and columns form ONE physical part.
// Z=0 is the finished seating plane; columns land at Z=-layer_pitch.
// cap is TOTAL slotted thickness; metal is only the optional bonded sheet.
// Supply cap via makerstack_rail_total_t() to retain printable backing.
// The base replaces tall columns with integral low feet (no lower T-nuts).
// channel=[width,depth,radius,wall]; nut=[width,clearance,guide length].
// post=[width,depth,seat,bore,hole,key X,Y,Z].
module makerstack_support(base = false, frame = frame_width,
	spacing = rail_spacing, pitch = layer_pitch, depth = frame_depth,
	cap = rail_thickness,
	channel = [nut_channel_width, nut_channel_depth,
		nut_channel_radius, nut_channel_wall],
	nut = [nut_width, fit_clearance, nut_guide_length],
	post = [column_width, column_depth, screw_seat, access_diameter,
		screw_clearance, key_width, key_depth, key_length], metal = 0) {
	w = channel[0] + 2 * channel[3];
	x = makerstack_post_x(frame, RACK_RAIL_HEIGHT);
	metal_t = max(0, metal);
	eps = 0.02;
	render(convexity = 8) union() {
		// Exact shared face at -cap: no overlap shim or channel cuts here.
		translate([0, 0, -cap])
			linear_extrude(cap - metal_t)
				makerstack_top_2d(frame, spacing, w, RACK_RAIL_HEIGHT,
					post[5] + 2 * nut[1]);
		difference() {
			union() {
				translate([0, 0, -depth])
					linear_extrude(depth - cap)
						makerstack_ring_2d(w, frame, spacing);
				makerstack_posts(x, spacing)
					if (base)
						translate([0, 0, -base_plane_z]) makerstack_foot();
					else
						translate([0, 0, -pitch])
							makerstack_column(pitch - depth, post[0], post[1],
								post[2], post[3], post[4],
								[post[5], post[6], post[7]]);
			}
			difference() {
				makerstack_nut_channels(frame, spacing, RACK_RAIL_HEIGHT,
					channel[0], channel[1], channel[2], cap);
				makerstack_nut_guides(frame, spacing, w, depth,
					nut[0], nut[1], nut[2], cap, RACK_RAIL_HEIGHT);
			}
			if (base && base_open_channels)
				makerstack_bottom_openings(frame, spacing, RACK_RAIL_HEIGHT,
					channel[0], depth, cap, post[0], post[1]);
			// Continue the shaft through the floor to the existing top slot.
			if (!base)
				makerstack_posts(x, spacing)
					translate([0, 0, -pitch + post[2]])
						cylinder(d = post[3], h = pitch - post[2] + eps);
			if (base && foot_style == "screw")
				makerstack_posts(x, spacing)
					for (sx = [-1, 1])
						translate([sx * foot_hole_spacing / 2, 0,
							-depth - eps])
							cylinder(d = foot_access_diameter,
								h = depth + 2 * eps);
		}
	}
}

// Fully printed by default; optional metal reinforces the printed rail.
// Bond the sheet to its backing. cap_lift only explodes that optional sheet.
module makerstack_frame(base = false, cap_lift = 0, frame = frame_width,
	spacing = rail_spacing, pitch = layer_pitch, depth = frame_depth,
	cap = rail_thickness,
	channel = [nut_channel_width, nut_channel_depth,
		nut_channel_radius, nut_channel_wall],
	nut = [nut_width, fit_clearance, nut_guide_length],
	post = [column_width, column_depth, screw_seat, access_diameter,
		screw_clearance, key_width, key_depth, key_length], metal = 0) {
	metal_t = max(0, metal);
	color("#9ba7b5")
		makerstack_support(base, frame, spacing, pitch, depth,
			cap, channel, nut, post, metal_t);
	if (metal_t > 0)
		color("#d7dee8") translate([0, 0, -metal_t + cap_lift])
			linear_extrude(metal_t)
				makerstack_top_2d(frame, spacing,
					channel[0] + 2 * channel[3], RACK_RAIL_HEIGHT,
					post[5] + 2 * nut[1]);
}

// Cutaway of the actual front rail, not a second copy of its profile.
// Open cut ends expose the channel; production frame pockets have end stops.
module makerstack_channel_section() {
	translate([0, rail_spacing / 2, frame_depth])
		intersection() {
			makerstack_frame(metal = rail_metal_thickness);
			translate([0, -rail_spacing / 2 - channel_support_width / 2,
				-frame_depth])
				cube([40, channel_support_width, frame_depth]);
		}
}

// Lower rail seats at Z=0. The head bears on the floor at Z=screw_seat.
// Printing this alone is a fit coupon, NOT a detachable upper connection.
module makerstack_column(height = column_height, width = column_width,
	depth = column_depth, seat = screw_seat, bore = access_diameter,
	hole = screw_clearance, key = [key_width, key_depth, key_length]) {
	eps = 0.02;
	difference() {
		union() {
			translate([-width / 2, -depth / 2, 0])
				cube([width, depth, height]);
			translate([0, 0, -key[2]]) makerstack_key(key);
		}
		translate([0, 0, -key[2] - eps])
			cylinder(d = hole, h = key[2] + seat + 2 * eps);
		translate([0, 0, seat])
			cylinder(d = bore, h = height - seat + eps);
	}
}

// Base at Z=0; stem joins the bottom support ring directly, without a bolt.
// Bond variant retains a flat, unperforated pad; adhesive is not modeled.
module makerstack_foot() {
	difference() {
		union() {
			linear_extrude(foot_thickness)
				offset(r = 2)
					square([foot_width - 4, channel_support_width - 4],
						center = true);
			translate([-column_width / 2, -column_depth / 2,
				foot_thickness])
				cube([column_width, column_depth,
					foot_seat_height - foot_thickness]);
		}
		if (foot_style == "screw")
			for (sx = [-1, 1])
				translate([sx * foot_hole_spacing / 2, 0, -cut_epsilon])
					cylinder(d = foot_hole_diameter,
						h = foot_thickness + 2 * cut_epsilon);
	}
}

// Illustrative, unthreaded M3 hardware at a LOWER rail's seating plane.
// Nut is shown locked across the slot, not in its insertion orientation.
module makerstack_joint_hardware() {
	color("#56606c") difference() {
		union() {
			translate([0, 0, screw_seat - screw_length])
				cylinder(d = screw_diameter, h = screw_length);
			translate([0, 0, screw_seat])
				cylinder(d = screw_head_diameter, h = screw_head_height);
		}
		translate([0, 0, screw_seat + screw_head_height - 1.5])
			cylinder(d = 2.8, h = 1.5 + cut_epsilon, $fn = 6);
	}
	color("#d4b864") difference() {
		translate([-nut_length / 2, -nut_width / 2,
			-rail_thickness - nut_thickness])
			cube([nut_length, nut_width, nut_thickness]);
		translate([0, 0, -rail_thickness - nut_thickness - cut_epsilon])
			cylinder(d = screw_diameter,
				h = nut_thickness + 2 * cut_epsilon);
	}
}

// Half of the actual two-tier joint, relocated to the origin for inspection.
// The tool extends from the recessed screw, through the upper slot.
module makerstack_joint_section() {
	intersection() {
		translate([-post_x, rail_spacing / 2, 0]) {
			makerstack_frame(true, metal = rail_metal_thickness);
			translate([0, 0, layer_pitch])
				makerstack_frame(metal = rail_metal_thickness);
		}
		translate([-20, 0, -frame_depth])
			cube([40, channel_support_width / 2, layer_pitch + frame_depth]);
	}
	if (show_hardware) makerstack_joint_hardware();
	if (show_driver)
		color("#b5e853", 0.45)
			translate([0, 0, screw_seat + screw_head_height])
				cylinder(d = driver_diameter, h = driver_reach);
}

// Each tier is secured before adding the next; no full-height tie rod.
// Explosion separates supports, optional metal, hardware, and sample panels.
module makerstack_assembly(explode = 0) {
	for (i = [0:1:layer_count - 1]) {
		z = base_plane_z + i * (layer_pitch + 2 * explode);
		translate([0, 0, z]) {
			makerstack_frame(i == 0, explode, metal = rail_metal_thickness);
			if (show_hardware && i > 0)
				translate([0, 0, -layer_pitch])
					makerstack_posts() makerstack_joint_hardware();
			if (panels == "all" || (panels == "top"
				&& i == layer_count - 1))
				translate([0, 0, 2 * explode])
					color("#8063bd")
						makerpanel(preview_panel_hp, panel_height_u);
		}
	}
}

// Part selectors put the selected physical part's lowest surface at Z=0.
// "column" and "foot" are inspection coupons, not separate assembly parts.
// "parts" is a sample layout; manual selector strings also remain available.
// "top" is the optional metal reinforcement outline for SVG/DXF export.
if (part == "assembly")
	makerstack_assembly();
else if (part == "exploded")
	makerstack_assembly(explode_gap);
else if (part == "frame")
	translate([0, 0, layer_pitch + key_length])
		makerstack_frame(metal = rail_metal_thickness);
else if (part == "base")
	translate([0, 0, base_plane_z])
		makerstack_frame(true, metal = rail_metal_thickness);
else if (part == "support")
	translate([0, 0, base_support ? base_plane_z : layer_pitch + key_length])
		makerstack_support(base_support, metal = rail_metal_thickness);
else if (part == "section")
	makerstack_channel_section();
else if (part == "joint")
	translate([0, 0, frame_depth]) makerstack_joint_section();
else if (part == "top")
	makerstack_top_2d();
else if (part == "column")
	translate([0, 0, key_length]) makerstack_column();
else if (part == "foot")
	makerstack_foot();
else if (part == "parts") {
	translate([0, 0, layer_pitch + key_length])
		makerstack_frame(metal = rail_metal_thickness);
	translate([frame_width / 2 + 30, -25, key_length])
		makerstack_column();
	translate([frame_width / 2 + 30, 20, 0])
		makerstack_foot();
}