// IrisMakerPanel
// This file builds an independent MakePanel for the Iris Keyboard by keeb.io.
// The panel is a flat laser cuttable or 3d printable plate where the keyboard can be mounted
// while the panel can be installed in a MakerRail compatible case or cyberdeck.

include <common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
verticalUnits = 4; // [1:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 35; // [4:1:40] MakerPanel horizontal pitch (HP) for panel width

// [Part Selection]
part = "assembly"; // [assembly, iris_keyboard, iris_keyboard_laser]

/* [Hidden] */
// Iris Keyboard Cutout
// The keyboard cutout is an svg which will be extruded to delete from the panel.
keyboard_panel_depth = 3; // mm.
keyboard_cutout = "IrisCutout.svg"; // Path to the SVG file for the keyboard cutout
keyboard_cutout_depth = 3; // Depth to extrude the cutout for deletion

// Positioning of the SVG cutout on the panel.
// The SVG is centered on the panel by default.
keyboard_cutout_offset_x = 10;
keyboard_cutout_offset_y = 0;

epsilon = 0.01;

// The lasert cut version will output an svg, while the 3d printed version will output an stl

// SVG user units are CSS pixels at 96 DPI (each path uses matrix(1.3333,…) to convert
// from PostScript pt to px).  OpenSCAD reads SVG user units as mm (1:1), so we must
// convert px → mm manually: 1 px = 25.4/96 mm ≈ 0.2646 mm.
SVG_SCALE = 1;//25.4 / 96;

module iris_keyboard_cutout_2d() {
	translate([keyboard_cutout_offset_x, keyboard_cutout_offset_y])
		scale([SVG_SCALE, SVG_SCALE, 1])
			import(keyboard_cutout, center=true);
}

module iris_keyboard_laser() {
	// 2D panel for SVG/DXF export
	difference() {
		makerpanel_2d(horizontalPitch, verticalUnits);
		iris_keyboard_cutout_2d();
	}
}

module iris_keyboard(thickness=keyboard_panel_depth) {
	// 3D printable panel (same XY geometry as laser version, extruded in Z)
	difference() {
		color("grey")
		makerpanel(horizontalPitch, verticalUnits, thickness=thickness);

		translate([0, 0, -epsilon])
			linear_extrude(height=max(keyboard_cutout_depth, thickness) + 2*epsilon)
				iris_keyboard_cutout_2d();
	}
}

// Visualization-only split-keyboard assembly. The two halves remain separate
// MakerPanels, with the second half mirrored across its local center and
// placed directly beside the first half.
module iris_keyboard_assembly() {
	panel_width_mm = hp_to_mm(horizontalPitch);
	translate([-panel_width_mm / 2, 0, 0])
		iris_keyboard();
	translate([panel_width_mm / 2, 0, 0])
		mirror([1, 0, 0])
			iris_keyboard();
}

if (part == "assembly") {
	iris_keyboard_assembly();
} else if (part == "iris_keyboard") {
	iris_keyboard();
} else if (part == "iris_keyboard_laser") {
	iris_keyboard_laser();
}
