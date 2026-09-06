// Prime79 keyboard panel
// This file builds one wide panel for an 80% Prime79 keyboard.
// The supplied DXF describes the keyboard plate cutout and keyboard mounting
// holes. MakerPanel supplies the actual panel boundary and rail mounting holes.

include <common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
verticalUnits = 4; // [1:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 70; // [70:1:80] MakerPanel horizontal pitch (HP) for panel width

// [Part Selection]
part = "assembly"; // [assembly, prime79_keyboard, prime79_keyboard_laser]

/* [Hidden] */
keyboard_panel_depth = 3; // mm
keyboard_cutout = "Prime79_outline.dxf";
keyboard_cutout_depth = 3; // mm

epsilon = 0.01;

module prime79_outline_2d() {
	import(keyboard_cutout, center=true);
}

module prime79_keyboard_laser() {
	// Standard MakerPanel boundary plus keyboard cutout for laser export.
	difference() {
		makerpanel_2d(horizontalPitch, verticalUnits);
		prime79_outline_2d();
	}
}

module prime79_keyboard(thickness=keyboard_panel_depth) {
	// Standard MakerPanel body includes the panel mounting holes.
	difference() {
		color("grey")
			makerpanel(horizontalPitch, verticalUnits, thickness=thickness);
		translate([0, 0, -epsilon])
			linear_extrude(height=max(keyboard_cutout_depth, thickness) + 2*epsilon)
				prime79_outline_2d();
	}
}

// Assembly is intentionally one wide keyboard panel; no mirrored half is
// added because Prime79 is a single integrated 80% keyboard.
module prime79_keyboard_assembly() {
	prime79_keyboard();
}

if (part == "assembly") {
	prime79_keyboard_assembly();
} else if (part == "prime79_keyboard") {
	prime79_keyboard();
} else if (part == "prime79_keyboard_laser") {
	prime79_keyboard_laser();
}
