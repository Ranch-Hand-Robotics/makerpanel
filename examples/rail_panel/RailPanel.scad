// RailPanel
// HP-by-U rack faceplate with integrated MakerRail slot rows.

include <makerpanel/common.scad>
use <makerpanel/panel.scad>
use <makerpanel/rack.scad>

/* [Customization] */
panelThickness = 3; // [1:0.5:3] Panel thickness in millimeters
horizontalPitch = 35; // [16:1:80] MakerPanel width in HP
verticalUnits = 2; // [1:1:8] MakerPanel height in U

/* [Part Selection] */
part = "rail_panel"; // [rail_panel, rail_panel_2d]

/* [Hidden] */
function effective_vertical_units() = max(1, verticalUnits);
function panel_width() = hp_to_mm(horizontalPitch);
function rack_hole_spacing() =
    panel_width() - 2 * RACK_RAIL_HEIGHT;
function center_clearance() =
    panel_width() - 2 * RACK_RAIL_HEIGHT;

module rail_panel_2d() {
    assert(horizontalPitch >= 16, "Horizontal pitch must be at least 16HP.");
    assert(panelThickness > 0, "Panel thickness must be positive.");
    assert(
        part == "rail_panel" || part == "rail_panel_2d",
        "Part must be rail_panel or rail_panel_2d."
    );

    if (effective_vertical_units() != verticalUnits) {
        echo("Legacy panel height is below 1U; using 1U.");
    }

    intersection() {
        makerpanel_2d(
            horizontalPitch,
            effective_vertical_units()
        );
        rack_faceplate_2d(
            rack_u=effective_vertical_units(),
            outer_width=panel_width(),
            hole_c2c=rack_hole_spacing(),
            center_clearance=center_clearance(),
            rack_mounting_holes=false,
            rail_edge_margin=0
        );
    }
}

module rail_panel(thickness=panelThickness) {
    linear_extrude(height=thickness)
        rail_panel_2d();
}

if (part == "rail_panel_2d") {
    rail_panel_2d();
} else {
    rail_panel();
}
