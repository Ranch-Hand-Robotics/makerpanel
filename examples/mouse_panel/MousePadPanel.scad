// MousePadPanel
// This file builds an independent MakePanel for a flat mouse pad. yep. That's it..
// The panel is a flat laser cuttable or 3d printable plate where the mouse pad can be mounted
// while the panel can be installed in a MakerRail compatible case or cyberdeck.

include <common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
mousepad_panel_depth = 3; // mm - thickness of the panel
verticalUnits = 5; // [1:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 35; // [4:1:40] MakerPanel horizontal pitch (HP) for panel width

// The mouse pad is just a maker panel with specific dimensions and no cutouts, 
// positioned on the right rear quadrant of the deck.

// However, it does have an interesting data point:
// Because the mousepad spans the keyboard bay AND right front of the deck, there needs to be 
// mounting holes in the mousepad area that are not obstructed by the keyboard bay.

epsilon = 0.01;

// [Part Selection]
parts = "mousepad_panel"; // [mousepad_panel, mousepad_panel_laser, assembly]

// ============================================
// Modules
// ============================================

module mousepad_panel_laser() {
	// 2D panel for SVG/DXF export - flat mousepad surface with no cutouts
	makerpanel_2d(horizontalPitch, verticalUnits);
}

module mousepad_panel(thickness = mousepad_panel_depth) {
	// 3D printable panel - flat mousepad surface with T-slot mounting holes
	makerpanel(horizontalPitch, verticalUnits, thickness=thickness);
}

module mousepad_assembly() {
	// Assembly view showing the mousepad panel
	// This can be used to verify mounting and positioning
	color("lightgray")
		mousepad_panel();
}

// ============================================
// Output
// ============================================

if (parts == "mousepad_panel") {
	mousepad_panel();
} else if (parts == "mousepad_panel_laser") {
	mousepad_panel_laser();
} else if (parts == "assembly") {
	mousepad_assembly();
}