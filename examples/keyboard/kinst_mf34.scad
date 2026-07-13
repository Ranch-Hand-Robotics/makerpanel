use <cmx.scad>

module kinst_mf34() {
    // Kinst MF34 keyboard with 34 keys, using Cherry MX switches.
    // This is a compact 75% layout with a function row and arrow keys.
    // The layout is designed for a 60% keyboard with additional keys on the right side.

    // Parameters for the keyboard layout
    key_pitch = 19.05; // mm, standard key pitch for Cherry MX switches
    key_depth = 18; // mm, depth of the keycap
    key_height = 10; // mm, height of the keycap
    wall_thickness = 1.5; // mm, thickness of the keycap walls

    // Generate the keycaps for the keyboard
    for (row = [0:4]) {
        for (col = [0:6]) {
            translate([col * key_pitch, row * key_pitch, 0])
                cherry_mx_keycap_3d(
                    u=1,
                    key_pitch=key_pitch,
                    cap_depth=key_depth,
                    cap_height=key_height,
                    wall=wall_thickness
                );
        }
    }

    // Additional keys on the right side (e.g., arrow keys)
    translate([7 * key_pitch, 2 * key_pitch, 0])
        cherry_mx_keycap_3d(
            u=1,
            key_pitch=key_pitch,
            cap_depth=key_depth,
            cap_height=key_height,
            wall=wall_thickness
        );
}