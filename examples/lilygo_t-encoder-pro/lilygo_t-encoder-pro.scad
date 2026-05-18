// LilyGo T-Encoder Pro Dial
// This is a simple panel for the LilyGo T-Encoder Pro, which is a rotary encoder with an attached PCB and optional battery, designed for handheld projects.
// The panel is a flat laser cuttable or 3d printable plate where the encoder can be mounted
// while the panel can be installed in a MakerRail compatible case or cyberdeck.

include <panel.scad>

/* [Parameters] */
panel_u = 1; //[1:1:4] MakerPanel units high for the bay height
panel_hp = 9; // [9:1:35] MakerPanel horizontal pitch for the bay width
panel_depth = 3; // mm.

module hidden() {}

lilygo_radius = 35.5/2; // mm, radius of the circular area for the encoder

module lilygo_panel() {
    // 3D printable panel (same XY geometry as laser version, extruded in Z)
    difference() {
        makerpanel(panel_hp, panel_u, thickness=panel_depth);

        // Cutout for the encoder
        translate([0, 0, -1])
            linear_extrude(height=panel_depth + 2)
                circle(r=lilygo_radius, $fn=32);

    }
}

lilygo_panel();