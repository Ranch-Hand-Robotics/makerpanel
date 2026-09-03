// 10-inch or 19-inch rack faceplate with integrated MakerRail slot rows.

include <makerpanel/common.scad>
use <makerpanel/rack.scad>

/* [Part Selection] */
part = "rail_panel"; // [rail_panel, rail_panel_2d]

/* [Customization] */
rackWidthInches = 10; // [10, 19] 10 inches (254 mm) or 19 inches (482.6 mm)
verticalUnits = 2; // [0:1:8] 0 = one offset-ear rail; rotate its mate 180 degrees


/* [Hidden] */
panelThickness = 3; // [1:0.5:3] Panel thickness in millimeters
function is_single_rail() = verticalUnits == 0;
function effective_vertical_units() = max(1, verticalUnits);
function rack_outer_width() = rack_outer_width_mm(rackWidthInches);
function rack_hole_spacing() = rack_mount_c2c_mm(rackWidthInches);
function center_clearance() = rack_center_clearance_mm(rackWidthInches);

module rail_panel_2d() {
    assert(
        rackWidthInches == 10 || rackWidthInches == 19,
        "Rack width must be 10 inches or 19 inches."
    );
    assert(panelThickness > 0, "Panel thickness must be positive.");
    assert(
        part == "rail_panel" || part == "rail_panel_2d",
        "Part must be rail_panel or rail_panel_2d."
    );

    if (is_single_rail()) {
        rack_single_rail_2d(
            outer_width=rack_outer_width(),
            hole_c2c=rack_hole_spacing(),
            center_clearance=center_clearance()
        );
    } else {
        rack_faceplate_2d(
            rack_u=effective_vertical_units(),
            outer_width=rack_outer_width(),
            hole_c2c=rack_hole_spacing(),
            center_clearance=center_clearance()
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
