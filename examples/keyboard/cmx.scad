// Cherry MX utility modules
// Lightweight dimensional primitives for keyboard design prototyping.
// All dimensions in mm.

// ============================================
// Helpers / defaults
// ============================================

/* [Parts] */
part = "mx_switch_3d"; // [mx_footprint_2d, mx_footprint_3d, mx_footprint_stab_2d, mx_footprint_stab_3d, mx_stabilizer_foot_2d, mx_stabilizer_foot_3d, mx_switch_3d, mx_keycap_3d, mx_wide_keycap_3d]

/* [Preview Parameters] */
key_u = 2; // [1:0.25:7]
preview_with_alignment_holes = false;
preview_stabilizer_span = 0; // 0 = auto by key_u
preview_footprint_thickness = 1.6; // [0.8:0.1:6] 3D preview extrusion height for 2D footprints

/* [Hidden] */
KEY_U = 19.05; // 1u key pitch
function inch(x) = x * 25.4;



// Common Cherry-style stabilizer center spacing by key width (approx).
// Override with an explicit value if your hardware differs.
function cherry_stabilizer_span(u) =
	(u <= 2) ? 23.88 :
	(u <= 2.25) ? 28.58 :
	(u <= 2.5) ? 33.34 :
	(u <= 2.75) ? 38.10 :
	(u <= 6.25) ? 100.00 :
	114.30; // ~7u

// ============================================
// 2D footprints (for plate cut geometry)
// ============================================

module cherry_mx_footprint_2d(
	cutout_size=14,
	corner_radius=0.5,
	alignment_hole_d=1.7,
	alignment_hole_y=5.08,
	with_alignment_holes=false
) {
	// 2D plate opening for a single Cherry MX switch.
	union() {
		if (corner_radius > 0) {
			offset(r=corner_radius)
				offset(delta=-corner_radius)
					square([cutout_size, cutout_size], center=true);
		} else {
			square([cutout_size, cutout_size], center=true);
		}

		if (with_alignment_holes) {
			translate([0, alignment_hole_y])
				circle(d=alignment_hole_d, $fn=32);
			translate([0, -alignment_hole_y])
				circle(d=alignment_hole_d, $fn=32);
		}
	}
}

module cherry_mx_stabilizer_foot_2d(
	neck_len = 1.525,  // thin neck length from the central square edge
	neck_h   = 9.40,   // neck (waist) full height  (~2 x 4.70)
	tab_len  = 6.75,   // tab body length
	tab_h    = 12.03,  // tab body full height    (~0.484")
	clip_h   = 3.23,   // outer clip prong height at each corner
	notch_x  = 0.825,  // outer-edge notch inset (~0.032")
	root_overlap = 1   // mm buried into the central square for a clean union
) {
	// A single stabilizer foot in local coordinates:
	//   x = 0             -> neck root (attaches to the central switch cutout)
	//   x = neck_len+tab_len -> outer edge of the foot
	// Symmetric about the X axis. Silhouette (outward): thin neck -> fat tab
	// -> notched outer edge leaving top/bottom clip prongs. Focus feature work here.
	hn   = neck_h / 2;            // neck half-height (~4.70)
	ht   = tab_h / 2;            // tab half-height (~6.015)
	length = neck_len + tab_len; // outer edge x
	yclip  = ht - clip_h;        // y where the outer notch steps in (~2.785)

	polygon(points=[
		[-root_overlap, hn],
		[neck_len, hn],
		[neck_len, ht],
		[length, ht],
		[length, yclip],
		[length - notch_x, yclip],
		[length - notch_x, -yclip],
		[length, -yclip],
		[length, -ht],
		[neck_len, -ht],
		[neck_len, -hn],
		[-root_overlap, -hn]
	]);
}

module cherry_mx_footprint_with_stabilizers_2d(
	u=2,
	cutout_size=14,
	stabilizer_span=undef,  // full width A (mm); undef => foot's native width
	corner_radius=0.5
) {
	// Composed cutout: central Cherry MX footprint unioned with a
	// stabilizer foot on each side.
	central_half = cutout_size / 2;      // neck root position
	tab_len      = 6.75;
	// Stretch the neck so the total width hits A, if provided.
	neck_len = is_undef(stabilizer_span)
		? 1.525
		: max(stabilizer_span / 2 - central_half - tab_len, 1.525);

	union() {
		cherry_mx_footprint_2d(cutout_size=cutout_size, corner_radius=corner_radius);

		translate([central_half, 0])
			cherry_mx_stabilizer_foot_2d(neck_len=neck_len, tab_len=tab_len);

		translate([-central_half, 0])
			mirror([1, 0, 0])
				cherry_mx_stabilizer_foot_2d(neck_len=neck_len, tab_len=tab_len);
	}
}

module cherry_mx_footprint_3d(
	thickness=1.6,
	cutout_size=14,
	corner_radius=0.5,
	alignment_hole_d=1.7,
	alignment_hole_y=5.08,
	with_alignment_holes=false
) {
	linear_extrude(height=thickness)
		cherry_mx_footprint_2d(
			cutout_size=cutout_size,
			corner_radius=corner_radius,
			alignment_hole_d=alignment_hole_d,
			alignment_hole_y=alignment_hole_y,
			with_alignment_holes=with_alignment_holes
		);
}

module cherry_mx_footprint_with_stabilizers_3d(
	thickness=1.6,
	u=2,
	cutout_size=14,
	stabilizer_span=undef,
	corner_radius=0.5
) {
	linear_extrude(height=thickness)
		cherry_mx_footprint_with_stabilizers_2d(
			u=u,
			cutout_size=cutout_size,
			stabilizer_span=stabilizer_span,
			corner_radius=corner_radius
		);
}

// ============================================
// 3D components
// ============================================

module cherry_mx_switch_3d(
	lower_w=14,
	lower_h=5,
	upper_w=15.6,
	upper_h=6.6,
	stem_w=4,
	stem_h=4,
	stem_rise=4,
	pin_d=1.5,
	pin_h=3.5
) {
	// Simple visual/fit model of a Cherry MX switch.
	// Origin: center XY at switch center, Z=0 on bottom of switch body.
	union() {
		// Lower housing
		translate([0, 0, lower_h/2])
			cube([lower_w, lower_w, lower_h], center=true);

		// Upper housing
		translate([0, 0, lower_h + upper_h/2])
			cube([upper_w, upper_w, upper_h], center=true);

		// Simplified stem tower
		translate([0, 0, lower_h + upper_h + stem_rise/2])
			cube([stem_w, stem_w, stem_rise], center=true);

		// Simplified two electrical pins under body
		translate([-2.54, 0, -pin_h/2])
			cylinder(d=pin_d, h=pin_h, center=true, $fn=20);
		translate([ 2.54, 0, -pin_h/2])
			cylinder(d=pin_d, h=pin_h, center=true, $fn=20);
	}
}

module cherry_mx_keycap_3d(
	u=1,
	key_pitch=KEY_U,
	cap_depth=18,
	cap_height=10,
	top_scale=0.88,
	wall=1.2,
	dish_depth=0.8
) {
	// Simplified keycap shell for a 1u-style keycap.
	// For wide keys, use cherry_mx_wide_keycap_3d().
	cap_width = u * key_pitch - 1.0;

	difference() {
		// Outer shell
		linear_extrude(height=cap_height, scale=[top_scale, top_scale])
			square([cap_width, cap_depth], center=true);

		// Hollow interior
		translate([0, 0, wall])
			linear_extrude(height=max(cap_height - wall, 0.1), scale=[top_scale, top_scale])
				square([max(cap_width - 2*wall, 0.1), max(cap_depth - 2*wall, 0.1)], center=true);

		// Top dish (simple spherical scoop)
		translate([0, 0, cap_height - dish_depth + cap_width])
			sphere(r=cap_width, $fn=64);
	}
}

module cherry_mx_wide_keycap_3d(
	u=2,
	key_pitch=KEY_U,
	cap_depth=18,
	cap_height=10,
	top_scale=0.90,
	wall=1.4,
	stabilizer_span=undef,
	stabilizer_stem_d=5.2,
	stabilizer_stem_h=4
) {
	// Wide keycap (2u+) with added stabilizer stem placeholders.
	stab_span = is_undef(stabilizer_span) ? cherry_stabilizer_span(u) : stabilizer_span;
	cap_width = u * key_pitch - 1.0;

	union() {
		cherry_mx_keycap_3d(
			u=u,
			key_pitch=key_pitch,
			cap_depth=cap_depth,
			cap_height=cap_height,
			top_scale=top_scale,
			wall=wall
		);

		// Underside stabilizer stems (simple cylinders)
		translate([-stab_span/2, 0, stabilizer_stem_h/2])
			cylinder(d=stabilizer_stem_d, h=stabilizer_stem_h, center=true, $fn=40);
		translate([ stab_span/2, 0, stabilizer_stem_h/2])
			cylinder(d=stabilizer_stem_d, h=stabilizer_stem_h, center=true, $fn=40);
	}
}

// ============================================
// Customizer render dispatch
// ============================================

if (part == "mx_footprint_2d") {
	cherry_mx_footprint_2d(with_alignment_holes=preview_with_alignment_holes);
} else if (part == "mx_footprint_3d") {
	cherry_mx_footprint_3d(
		thickness=preview_footprint_thickness,
		with_alignment_holes=preview_with_alignment_holes
	);
} else if (part == "mx_footprint_stab_2d") {
	cherry_mx_footprint_with_stabilizers_2d(
		u=key_u,
		stabilizer_span=(preview_stabilizer_span <= 0 ? undef : preview_stabilizer_span)
	);
} else if (part == "mx_footprint_stab_3d") {
	cherry_mx_footprint_with_stabilizers_3d(
		thickness=preview_footprint_thickness,
		u=key_u,
		stabilizer_span=(preview_stabilizer_span <= 0 ? undef : preview_stabilizer_span)
	);
} else if (part == "mx_stabilizer_foot_2d") {
	cherry_mx_stabilizer_foot_2d();
} else if (part == "mx_stabilizer_foot_3d") {
	linear_extrude(height=preview_footprint_thickness)
		cherry_mx_stabilizer_foot_2d();
} else if (part == "mx_switch_3d") {
	cherry_mx_switch_3d();
} else if (part == "mx_keycap_3d") {
	cherry_mx_keycap_3d(u=key_u);
} else if (part == "mx_wide_keycap_3d") {
	cherry_mx_wide_keycap_3d(
		u=max(key_u, 2),
		stabilizer_span=(preview_stabilizer_span <= 0 ? undef : preview_stabilizer_span)
	);
}

