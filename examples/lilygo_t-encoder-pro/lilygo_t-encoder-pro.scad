// LilyGo T-Encoder Pro Dial
// This is a simple panel for the LilyGo T-Encoder Pro, which is a rotary encoder with an attached PCB and optional battery, designed for handheld projects.
// The panel is a flat laser cuttable or 3d printable plate where the encoder can be mounted
// while the panel can be installed in a MakerRail compatible case or cyberdeck.

include <panel.scad>

/* [Parameters] */
verticalUnits = 1; //[1:1:8] MakerPanel vertical units (U) for panel height
horizontalPitch = 9; // [4:1:40] MakerPanel horizontal pitch (HP) for panel width
panel_depth = 3; // mm.

module hidden() {}

lilygo_radius = 35.5/2; // mm, radius of the circular area for the encoder

module lilygo_panel() {
    // 3D printable panel (same XY geometry as laser version, extruded in Z)
    difference() {
        makerpanel(horizontalPitch, verticalUnits, thickness=panel_depth);

        // Cutout for the encoder
        translate([0, 0, -1])
            linear_extrude(height=panel_depth + 2)
                circle(r=lilygo_radius, $fn=32);

    }
}

lilygo_panel();