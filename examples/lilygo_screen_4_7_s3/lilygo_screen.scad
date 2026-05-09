// LilyGo Screen 4.7" S3
// This is a simple panel for the LilyGo Screen 4.7" S3,
// which is a small screen with an attached PCB and optional battery, designed for handheld projects.
// The panel is a flat laser cuttable or 3d printable plate where the screen can be mounted
// while the panel can be installed in a MakerRail compatible case or cyberdeck.

// The screen is composed of two main parts: the screen itself, 
// and the attached PCB/battery. The screen is connected to the PCB via a ribbon cable.
// for the maker panel example, the screen is double sided taped to top of the panel,
// the ribbon cable is routed through a cutout in the panel, and the PCB/battery is 
// mounted to the back of the panel with double stick tape.

include <panel.scad>

/* [Part Selection] */
part = "assembly"; // [assembly, lilygo_screen, lilygo_pcb, lilygo_panel]

/* [Parameters] */

screen_bay_u = 2; // MakerPanel units high for the screen bay height
screen_bay_hp = 26; // MakerPanel horizontal pitch for the screen half.
screen_panel_depth = 3; // mm.

ribbon_cutout_w = 10; // mm width of the cutout for the ribbon cable
ribbon_cutout_h = 30; // mm height of the cutout for the ribbon cable
ribbon_cutout_offset_x = 5; // mm horizontal offset of the ribbon cutout from the side of the panel
ribbon_cutout_offset_y = 0; // mm vertical offset of the ribbon cutout from the center of the panel

module lilygo_makerpanel() {
    // 3D printable panel (same XY geometry as laser version, extruded in Z)
    difference() {
        makerpanel(screen_bay_hp, screen_bay_u, thickness=screen_panel_depth);

        offset_x_effective = hp_to_mm(screen_bay_hp)/2 - ribbon_cutout_w/2 - ribbon_cutout_offset_x;
        // Cutout for the ribbon cable
        translate([offset_x_effective, ribbon_cutout_offset_y, 0])
            cube([ribbon_cutout_w, ribbon_cutout_h, 2 * screen_panel_depth], center=true);
    }
}

module lilygo_screen() {

    // extruded to 2mm, 3mm screen corners, 120mm wide, 67mm tall 
    screen_rect_w = 120;
    screen_rect_h = 67;
    screen_rect_r = 3;
    screen_rect_thickness = 2;
    translate([0, 0, screen_rect_thickness/2])
        cube([screen_rect_w, screen_rect_h, screen_rect_thickness], center=true);
}

module lilygo_pcb() {
    // simple rectangle for the PCB, 118mm wide, 63mm tall, extruded to 1.6mm
    pcb_w = 118;
    pcb_h = 63;
    pcb_thickness = 8; //mm, just pcb components, no battery or screen thickness
    translate([0, 0, pcb_thickness/2])
        cube([pcb_w, pcb_h, pcb_thickness], center=true);
}

if (part == "assembly") {
    // Full assembly with screen, PCB, and panel
    // For simplicity, this example only models the panel and cutout, not the actual screen or PCB geometry.
    lilygo_makerpanel();
} else if (part == "lilygo_screen") {
    lilygo_screen();
} else if (part == "lilygo_pcb") {
    lilygo_pcb();
} else if (part == "lilygo_panel") {
    // Just the panel with cutout
    lilygo_makerpanel();
}



