// Captured-slider monitor mount. +Y = panel rear; +Z = up; axes parallel X.
// Carrier +Y is its top, +Z its display face: positive X rotation only.
// Two rear braces and ONE transverse M4x45 screw give one nominal DOF.
// Prototype, NOT load-rated. Support while moving AND deployed: no lock,
// counterbalance or transport latch. Rear pads stop over-opening only.
include <makerpanel/common.scad>
include <makerpanel/panel.scad>
use <examples/vent_panel/IsoGridScad/isogrid.scad>

/* [Customization] */
part = "assembly"; // [assembly, maker_panel, vesa_panel, brace, brace_2d]
metal_thickness = 4; // [1:0.5:4]
// Optional arm-pivot washers; zero omits them from the assembly.
washer_thickness = 0; // [0:0.1:2]
// Total free space across both sides of the arm/optional washer stack.
pivot_clearance = 0.2; // [0:0.05:1]
verticalUnits = 4; // [1:1:8]
horizontalPitch = 35; // [4:1:40]
deployment = 0; // [0:0.01:1]
show_monitor = true;
show_hardware = true;
monitor_width = 700;
monitor_height = 190;
monitor_depth = 15;
// Distance from the actual monitor bottom to the VESA screw centers (mm).
monitor_row_offset = 90;
monitor_offset_x = 70;
panel_depth = 3;
vesa_plate_width = 0;
base_isogrid = true;
carrier_isogrid = true;
grid_triangle = 15; // [10:1:30] Triangle side, not perpendicular pitch.
grid_hole = 5; // [0:0.5:10] Intersection hole diameter, matching VentPanel.
grid_rib = 3; // [3:0.5:5] Retained solid stroke width.
grid_border = 10; // [10:1:20] Solid perimeter, before functional holes.
grid_margin = 4; // [4:0.5:8] OUTSIDE each structural XY footprint.
mount_washer_diameter = 7; // Bearing envelope only; no new seats.
vesa_bearing_diameter = 9; // Larger of purchased washer/nut footprint.

/* [Hidden] */
module hidden() {}
grid_eps = 0.01;
grid_facets = 64;
mount_pad_radius = max(8, mount_washer_diameter / 2 + grid_margin);
vesa_pad_radius = max(8, vesa_bearing_diameter / 2 + grid_margin);
panel_width = hp_to_mm(horizontalPitch);
panel_height = u_to_mm(verticalUnits);
panel_front = -panel_height / 2;
panel_rear = panel_height / 2;
deployed_angle = 90;
brace_lane = 63;
link_radius = 6;
pivot_radius = 8;
// Moving round bosses must also clear the panel, not only the M4 shaft.
slider_z = panel_depth + pivot_radius + 0.2;
bore_radius = 2.7;
cheek_thickness = 8;
clevis_gap = metal_thickness + 2 * washer_thickness + pivot_clearance;
cheek_offset = clevis_gap / 2 + cheek_thickness / 2;
bolt_radius = 2.5;
nut_radius = 4.7; // Circumscribes an 8 mm across-flats M5 hex nut.
nut_thickness = 4;
head_radius = 4.5;
head_thickness = 3;
bolt_extension = 0.5;
thread_clearance = 0.1; // Preview relief only; real nuts engage metal threads.
overlap = 0.5;

// One M4x45 screw passes through both lugs and the full-width closed slot.
// Lower/align carrier FIRST at FRONT; then insert screw along +X.
// Preserve the housing's YZ envelope independently of the smaller bore.
track_width = 20;
track_half_width = track_width / 2;
housing_envelope_radius = 4.2;
slot_radius = 2.25;
track_ligament = 3;
track_top = slider_z + housing_envelope_radius + track_ligament;
slider_running_gap = 0.5;
slider_lug_thickness = 8;
slider_lug_inner = track_half_width + slider_running_gap;
slider_lug_outer = slider_lug_inner + slider_lug_thickness;
slider_lug_radius = 8;
slider_bore = 2.25;
slider_bolt_length = 45; // Under head, not overall screw length.
slider_bolt_radius = 2;
slider_head_radius = 3.5;
slider_head_height = 4;
slider_washer_thickness = 0.8;
slider_washer_radius = 4.5;
slider_washer_bore = 2.15;
slider_nut_af = 7;
slider_nut_radius = slider_nut_af / sqrt(3); // Conservative hex envelope.
slider_nut_thickness = 5; // M4 nyloc; verify purchased hardware.
slider_nut_bore = 2.1; // Actual preview ring relief, not tap-drill size.
slider_thread_pitch = 0.7;
slider_stack = track_width + 2 * slider_running_gap
    + 2 * slider_lug_thickness + 2 * slider_washer_thickness
    + slider_nut_thickness;
slider_protrusion = slider_bolt_length - slider_stack;
slider_head_x = -slider_lug_outer - slider_washer_thickness;
slider_tip_x = slider_head_x + slider_bolt_length;
slider_nut_x = slider_lug_outer + slider_washer_thickness;
slider_hardware_reach = max(-slider_head_x + slider_head_height,
    slider_tip_x, slider_nut_x + slider_nut_thickness);
// Put the bottom AXLE below the actual screen edge at 90 degrees.
// The broad bottom tabs reach this edge; the plate has no lower overhang.
monitor_bottom_y = housing_envelope_radius + track_ligament + 0.6;
plate_bottom = max(pivot_radius, monitor_bottom_y) + 0.3;
plate_thickness = 3;
plate_top = plate_bottom + plate_thickness;
plate_start = monitor_bottom_y;
monitor_top_y = monitor_bottom_y + monitor_height;
monitor_center_y = monitor_bottom_y + monitor_height / 2;
vesa_row_y = monitor_bottom_y + monitor_row_offset;
vesa_spacing = 75;
vesa_bore = 2.25;
vesa_margin = 9;
plate_end = vesa_row_y + 10;
// Flush housing and complete lower lugs set the folded axle, not the row.
// Keep the rear anchors fixed; D moves below the physical plate midpoint.
anchor_rear_inset = pivot_radius + 2.1;
fixed_b = [panel_rear - anchor_rear_inset, slider_z];
slider_start = panel_front + slider_lug_radius;
carrier_span = (fixed_b[0] - slider_start - 1) / 2;
brace_length = carrier_span + 1;
// Keep the slider load path into the full D-pivot band, not past it.
slider_rib_end = min(plate_end, carrier_span + 8 + grid_margin);
// Define the stow footprint before the plate bounds that depend on it.
stow_depth = 10;
stow_width = 10;
// Keep the widened stops outside the metal-arm sweep, even at 4 mm stock.
stow_lane = max(69, brace_lane + metal_thickness / 2 + stow_width / 2 + 0.2);
required_left = min(-brace_lane - clevis_gap / 2 - cheek_thickness - 2,
    -stow_lane - stow_width / 2,
    monitor_offset_x - vesa_spacing / 2 - vesa_margin);
required_right = max(brace_lane + clevis_gap / 2 + cheek_thickness + 2,
    stow_lane + stow_width / 2,
    monitor_offset_x + vesa_spacing / 2 + vesa_margin);
plate_extra = max(0, vesa_plate_width - required_right + required_left) / 2;
plate_left = required_left - plate_extra;
plate_right = required_right + plate_extra;

// Negative horizontal branch: D remains FRONT of B throughout the stroke.
// Housing joins the panel over its entire length, flush at both Y ends.
// The slot follows reachable motion only; its rear reserve stays solid.
pad_thickness = 1.5; // Vertical thickness of bonded elastomer skin.
// Outside the slider hardware and inside the metal arms (inner X>=61).
pad_lane = 54;
pad_width = 12;
branch_end = sqrt(pow(brace_length, 2)
    - pow(carrier_span * sin(deployed_angle), 2));
slider_end = fixed_b[0] - carrier_span * cos(deployed_angle) - branch_end;
track_front = panel_front;
track_rear = panel_rear;
pad_back = [slider_end + monitor_bottom_y * cos(deployed_angle)
    - plate_top * sin(deployed_angle),
    slider_z + monitor_bottom_y * sin(deployed_angle)
        + plate_top * cos(deployed_angle)];
pad_front = pad_back + [-monitor_depth * sin(deployed_angle),
    monitor_depth * cos(deployed_angle)];
stow_pad_thickness = 0.5; // Separate from the 1.5 mm rear cushions.
magnet_diameter = 6;
magnet_thickness = 2;
magnet_pocket_diameter = 6.2;
magnet_pocket_depth = 2.1;
magnet_facets = 64;
// Keep outer supports ahead of the folded middle-pivot cheeks, not
// merely outside the narrower metal arms. Their carrier pockets follow.
stow_margin = 19.4;
stow_pivot_gap = 2;
stow_rear_y = min(
    min(panel_rear, slider_start + plate_end)
        - stow_depth / 2 - stow_margin,
    slider_start + carrier_span - pivot_radius
        - stow_depth / 2 - stow_pivot_gap);
// If the rear candidate is not behind the standing screen, place the
// whole pad ahead of it. This also accommodates lower VESA row inputs.
stow_screen_gap = 2;
stow_y = stow_rear_y - stow_depth / 2 >= pad_back[0] + stow_screen_gap
    ? stow_rear_y
    : min(stow_rear_y, pad_front[0] - stow_depth / 2 - stow_screen_gap);
stow_top = slider_z + plate_bottom;
// Inboard stow posts follow the folded carrier's middle (D) pivot band.
// Their matching seats remain compact and entirely under the plate.
dock_lane = 35;
dock_width = 10;
dock_stow_wall = 1.55; // Retained fore/aft pocket wall: 9.3 mm post depth.
dock_depth = magnet_pocket_diameter + 2 * dock_stow_wall;
dock_y = slider_start + carrier_span;
dock_contact_z = pad_back[1] - 3; // Folded contact 3 mm below screen stop.
dock_pad_thickness = 0.5;
dock_top = dock_contact_z - dock_pad_thickness;
// The pedestals meet these broad underside seats ONLY when folded flat.
// Invert the folded translation so both magnet pairs move together.
dock_fold_y = dock_y - slider_start;
dock_fold_bottom = dock_contact_z - slider_z;
dock_fold_top = plate_bottom + 2;
// Local pocket-sized bosses, not bars extending beyond the plate.
dock_fold_start = dock_fold_y - dock_depth / 2;
validation_steps = 1000;

function yz_rotate(p, a) = [p[0] * cos(a) - p[1] * sin(a),
    p[0] * sin(a) + p[1] * cos(a)];
function carrier_vector(p, t=deployment) =
    yz_rotate(p, carrier_angle(t));
function carrier_angle(t=deployment) = t * deployed_angle;
function branch_distance(t=deployment) =
    let(h2 = pow(brace_length, 2)
        - pow(carrier_span * sin(carrier_angle(t)), 2))
    assert(h2 > 0, "Unreachable brace or toggle") sqrt(h2);
function slider(t=deployment) = [fixed_b[0]
    - carrier_span * cos(carrier_angle(t)) - branch_distance(t), slider_z];
function carrier_world_yz(p, t=deployment) = slider(t) + carrier_vector(p, t);
function carrier_world(p, t=deployment) =
    let(q = carrier_world_yz([p[1], p[2]], t)) [p[0], q[0], q[1]];
function brace_tip(t=deployment) = carrier_world_yz([carrier_span, 0], t);
function monitor_bottom(t=deployment) =
    carrier_world([monitor_offset_x, monitor_bottom_y, plate_top], t);
function monitor_corners(t=deployment) = [
    for (x = [monitor_offset_x - monitor_width / 2,
            monitor_offset_x + monitor_width / 2],
        y = [monitor_bottom_y, monitor_top_y],
        z = [plate_top, plate_top + monitor_depth])
        carrier_world([x, y, z], t)
];
function vesa_x(side) = monitor_offset_x + side * vesa_spacing / 2;
function clevis_inner() = brace_lane - clevis_gap / 2 - cheek_thickness;
function clevis_outer() = brace_lane + clevis_gap / 2 + cheek_thickness;
function handed(side, lo, hi) =
    [min(side * lo, side * hi), max(side * lo, side * hi)];
function cheek_x(side, cheek) = handed(side,
    brace_lane + cheek * cheek_offset - cheek_thickness / 2,
    brace_lane + cheek * cheek_offset + cheek_thickness / 2);

// Exact tables drive rendering and inline checks. Boxes: [name, XYZ lo/hi].
// Rounds/cuts: [name, X lo/hi, YZ start/end, radius].
function base_boxes() = concat([
    ["track", [-track_half_width, track_front, panel_depth - overlap],
        [track_half_width, track_rear, track_top]]
], [for (side = [-1, 1], cheek = [-1, 1]) let(x = cheek_x(side, cheek))
    ["brace_foot", [x[0], fixed_b[0] - pivot_radius, panel_depth - overlap],
        [x[1], fixed_b[0] + pivot_radius, fixed_b[1]]]
], [for (side = [-1, 1])
    ["stow_stop", [side * stow_lane - stow_width / 2,
        stow_y - stow_depth / 2, panel_depth - overlap],
        [side * stow_lane + stow_width / 2,
        stow_y + stow_depth / 2, stow_top - stow_pad_thickness]]
], [for (side = [-1, 1])
    ["dock_pedestal", [side * dock_lane - dock_width / 2,
        dock_y - dock_depth / 2, panel_depth - overlap],
        [side * dock_lane + dock_width / 2,
        dock_y + dock_depth / 2, dock_top]]]);
function base_rounds() = [
    for (side = [-1, 1], cheek = [-1, 1]) let(x = cheek_x(side, cheek))
    ["B_cheek", x[0], x[1], fixed_b, fixed_b, pivot_radius]
];
function base_cuts() = concat([
    for (side = [-1, 1]) let(x = handed(side,
        clevis_inner() - 1, clevis_outer() + 1))
    ["B_bore", x[0], x[1], fixed_b, fixed_b, bore_radius]
], [
    ["slider_slot", -track_half_width - 1, track_half_width + 1,
        [slider_start, slider_z],
        [slider_end, slider_z], slot_radius]
]);
function carrier_boxes() = concat([
    ["plate", [plate_left, plate_start, plate_bottom],
        [plate_right, plate_end, plate_top]]
], [for (side = [-1, 1]) let(x = handed(side,
        slider_lug_inner, slider_lug_outer))
    ["slider_riser", [x[0], 0, 0],
        // End at the brace band; the plate carries the VESA row above it.
        [x[1], slider_rib_end, plate_bottom + 2]]
], [for (side = [-1, 1], cheek = [-1, 1]) let(x = cheek_x(side, cheek))
    ["D_riser", [x[0], carrier_span - 8, 0],
        [x[1], carrier_span + 8, plate_bottom + 2]]
], [for (side = [-1, 1])
    ["dock_fold_boss", [side * dock_lane - dock_width / 2,
        dock_fold_start, dock_fold_bottom],
        [side * dock_lane + dock_width / 2,
        dock_fold_y + dock_depth / 2, dock_fold_top]]
]);
function carrier_rounds() = concat([
    for (side = [-1, 1]) let(x = handed(side,
        slider_lug_inner, slider_lug_outer))
    ["slider_lug", x[0], x[1], [0, 0], [0, 0], slider_lug_radius]
], [for (side = [-1, 1], cheek = [-1, 1]) let(x = cheek_x(side, cheek))
    ["D_cheek", x[0], x[1], [carrier_span, 0],
        [carrier_span, 0], pivot_radius]
]);
function carrier_cuts() = concat([
    for (side = [-1, 1]) let(x = handed(side,
        slider_lug_inner - 1, slider_lug_outer + 1))
    ["slider_bore", x[0], x[1], [0, 0], [0, 0], slider_bore]
], [for (side = [-1, 1]) let(x = handed(side,
        clevis_inner() - 1, clevis_outer() + 1))
    ["D_bore", x[0], x[1], [carrier_span, 0],
        [carrier_span, 0], bore_radius]
]);
// Rings: [name, positive-side X start/end, radius, bore radius].
function brace_hardware() = [
    ["bolt", clevis_inner() - nut_thickness - bolt_extension,
        clevis_outer(), bolt_radius, 0],
    ["bolt", clevis_outer(), clevis_outer() + head_thickness, head_radius, 0],
    ["nut", clevis_inner() - nut_thickness, clevis_inner(),
        nut_radius, bolt_radius + thread_clearance],
    if (washer_thickness > 0)
    ["washer_i", brace_lane - metal_thickness / 2 - washer_thickness,
        brace_lane - metal_thickness / 2, head_radius, bore_radius],
    if (washer_thickness > 0)
    ["washer_o", brace_lane + metal_thickness / 2,
        brace_lane + metal_thickness / 2 + washer_thickness,
        head_radius, bore_radius]
];
// Absolute X intervals: render ONCE, never mirror this asymmetric stack.
function slider_bolt_hardware() = [
    ["bolt", slider_head_x, slider_tip_x, slider_bolt_radius, 0],
    ["bolt", slider_head_x - slider_head_height, slider_head_x,
        slider_head_radius, 0]
];
function slider_washer_hardware() = [
    ["washer_head", slider_head_x, -slider_lug_outer,
        slider_washer_radius, slider_washer_bore],
    ["washer_nut", slider_lug_outer, slider_nut_x,
        slider_washer_radius, slider_washer_bore]
];
function slider_locknut_hardware() = [
    ["locknut", slider_nut_x, slider_nut_x + slider_nut_thickness,
        slider_nut_radius, slider_nut_bore]
];
function slider_hardware() = concat(slider_bolt_hardware(),
    slider_washer_hardware(), slider_locknut_hardware());
function rear_support_yz() = [
    [pad_back[0], panel_depth - overlap],
    [pad_front[0], panel_depth - overlap],
    [pad_front[0], pad_front[1] - pad_thickness],
    [pad_back[0], pad_back[1] - pad_thickness]
];
function rear_pad_yz() = [
    [pad_back[0], pad_back[1] - pad_thickness],
    [pad_front[0], pad_front[1] - pad_thickness], pad_front, pad_back
];

// Blind Z pockets: [XY center, radius, Z floor, Z ceiling], part-local.
// Base opens upward; carrier opens downward. EPS extends ONLY into air.
function magnet_pockets(carrier) = [for (side = [-1, 1])
    [[side * stow_lane, stow_y - (carrier ? slider_start : 0)],
     magnet_pocket_diameter / 2,
     carrier ? plate_bottom
        : stow_top - stow_pad_thickness - magnet_pocket_depth,
     carrier ? plate_bottom + magnet_pocket_depth
        : stow_top - stow_pad_thickness]
];
module magnet_voids(carrier) {
    for (p = magnet_pockets(carrier))
        translate([p[0][0], p[0][1], p[2] - (carrier ? grid_eps : 0)])
            cylinder(r=p[1], h=p[3] - p[2] + grid_eps, $fn=magnet_facets);
}

// Two inboard carrier Z pockets: eight magnets total, four folded pairs.
// The cavity ends below the skin; keepouts retain its solid roof/root.
function dock_fold_magnet_pockets() = [for (side = [-1, 1])
    [[side * dock_lane, dock_fold_y], magnet_pocket_diameter / 2,
     dock_fold_bottom, dock_fold_bottom + magnet_pocket_depth]
];
module dock_fold_magnet_voids() {
    for (p = dock_fold_magnet_pockets())
        translate([p[0][0], p[0][1], p[2] - grid_eps])
            cylinder(r=p[1], h=p[3] - p[2] + grid_eps, $fn=magnet_facets);
}

// Inboard base Z pockets open upward toward the folded underside seats.
function dock_magnet_pockets() = [for (side = [-1, 1])
    [[side * dock_lane, dock_y],
     magnet_pocket_diameter / 2,
     dock_top - magnet_pocket_depth, dock_top]
];
module dock_magnet_voids() {
    for (p = dock_magnet_pockets())
        translate([p[0][0], p[0][1], p[2]])
            cylinder(r=p[1], h=p[3] - p[2] + grid_eps,
                $fn=magnet_facets);
}

// Skin rectangles and keepouts are XY, in each part's own coordinates.
// Project entire root envelopes, including round feet, not just centers.
function skin_bounds(carrier) = carrier
    ? [[plate_left, plate_start], [plate_right, plate_end]]
    : [[-panel_width / 2, panel_front], [panel_width / 2, panel_rear]];
function skin_roots(carrier) = concat([
    for (b = carrier ? carrier_boxes() : base_boxes())
        if (b[0] != "plate") [[b[1][0], b[1][1]], [b[2][0], b[2][1]]]
], [
    for (p = carrier ? carrier_rounds() : base_rounds())
        [[p[1], min(p[3][0], p[4][0]) - p[5]],
         [p[2], max(p[3][0], p[4][0]) + p[5]]]
], carrier ? [
    for (b = base_boxes()) if (b[0] == "stow_stop")
        [[b[1][0], b[1][1] - slider_start],
         [b[2][0], b[2][1] - slider_start]]
] : [
    for (side = [-1, 1])
        [[side * pad_lane - pad_width / 2,
            min([for (p = rear_support_yz()) p[0]])],
         [side * pad_lane + pad_width / 2,
            max([for (p = rear_support_yz()) p[0]])]]
]);
// Bands span the entire carrier, linking both side mounts, ribs and border.
function skin_bands(carrier) = carrier ? [
    [[plate_left, min([for (b = carrier_boxes())
        if (b[0] == "D_riser") b[1][1]]) - grid_margin],
     [plate_right, max([for (b = carrier_boxes())
        if (b[0] == "D_riser") b[2][1]]) + grid_margin]],
    [[plate_left, vesa_row_y - vesa_pad_radius],
     [plate_right, vesa_row_y + vesa_pad_radius]]
] : [];
// Pads retain surrounding material only: existing bores remain subtractive.
function skin_pads(carrier) = carrier ? [
    for (side = [-1, 1]) [vesa_x(side), vesa_row_y, vesa_pad_radius]
] : [
    for (sx = [-1, 1], sy = [-1, 1])
        [sx * (panel_width / 2 - RACK_RAIL_HEIGHT / 2),
         sy * (panel_height / 2 - RACK_RAIL_HEIGHT / 2), mount_pad_radius]
];
module skin_rectangle(bounds, margin=0) {
    translate(bounds[0] - [margin, margin])
        square(bounds[1] - bounds[0] + [2 * margin, 2 * margin]);
}
module skin_keepouts(carrier) {
    for (r = skin_roots(carrier)) skin_rectangle(r, grid_margin);
    for (r = skin_bands(carrier)) skin_rectangle(r);
    for (p = skin_pads(carrier)) translate([p[0], p[1]])
        // Circumscribed polygon: even facet midpoints retain full radius.
        circle(r=p[2] / cos(180 / grid_facets), $fn=grid_facets);
}
module skin_voids(carrier) {
    bounds = skin_bounds(carrier);
    size = bounds[1] - bounds[0];
    bottom = carrier ? plate_bottom : 0;
    depth = carrier ? plate_thickness : panel_depth;
    translate([0, 0, bottom - grid_eps])
        linear_extrude(height=depth + 2 * grid_eps)
            difference() {
                skin_rectangle(bounds, -grid_border);
                // Library returns POSITIVE ribs. Subtract their complement.
                translate((bounds[0] + bounds[1]) / 2)
                    isogrid_rect(size[0], size[1],
                        triangle_size=grid_triangle, thickness=grid_rib,
                        extrude=0, hole_size=grid_hole,
                        top_chamfer=0, bottom_chamfer=0);
                skin_keepouts(carrier);
            }
}
module bounds_box(box) {
    translate((box[1] + box[2]) / 2)
        cube(box[2] - box[1], center=true);
}
module axis_cylinder(r, h) {
    rotate([0, 90, 0]) cylinder(r=r, h=h, center=true, $fn=48);
}
module round_solid(p) {
    hull() for (q = [p[3], p[4]])
        translate([(p[1] + p[2]) / 2, q[0], q[1]])
            axis_cylinder(p[5], p[2] - p[1]);
}
module yz_prism(x, width, points) {
    translate([x, 0, 0]) multmatrix([
        [0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]])
        linear_extrude(height=width) polygon(points);
}
module maker_panel() {
    difference() {
        union() {
            makerpanel(horizontalPitch, verticalUnits, thickness=panel_depth);
            for (box = base_boxes()) bounds_box(box);
            for (p = base_rounds()) round_solid(p);
            for (side = [-1, 1])
                yz_prism(side * pad_lane - pad_width / 2,
                    pad_width, rear_support_yz());
        }
        for (p = base_cuts()) round_solid(p);
        magnet_voids(false);
        dock_magnet_voids();
        if (base_isogrid) skin_voids(false);
    }
}
module vesa_panel() {
    difference() {
        union() {
            for (box = carrier_boxes()) bounds_box(box);
            for (p = carrier_rounds()) round_solid(p);
        }
        for (p = carrier_cuts()) round_solid(p);
        magnet_voids(true);
        dock_fold_magnet_voids();
        if (carrier_isogrid) skin_voids(true);
        for (side = [-1, 1])
            translate([vesa_x(side), vesa_row_y, -1])
                cylinder(r=vesa_bore, h=plate_top + 2, $fn=48);
    }
    // Deliberately NO VESA bosses: monitor back is flush at plate_top.
}
module brace_2d() {
    difference() {
        hull() for (y = [0, brace_length])
            translate([0, y]) circle(r=link_radius, $fn=48);
        for (y = [0, brace_length])
            translate([0, y]) circle(r=bore_radius, $fn=48);
    }
}
module brace() {
    rotate([0, 90, 0]) linear_extrude(height=metal_thickness, center=true)
        brace_2d();
}
module ring(r, bore, height) {
    difference() {
        cylinder(r=r, h=height, $fn=48);
        if (bore > 0) translate([0, 0, -1])
            cylinder(r=bore, h=height + 2, $fn=48);
    }
}
module hardware_set(side, p, parts) {
    for (h = parts) {
        x = handed(side, h[1], h[2]);
        translate([x[0], p[0], p[1]]) rotate([0, 90, 0])
            ring(h[3], h[4], x[1] - x[0]);
    }
}
module rear_pad() {
    translate([0, -pad_back[0], -pad_back[1] + pad_thickness])
        yz_prism(0, pad_width, rear_pad_yz());
}
module stow_pad() {
    difference() {
        cube([stow_width, stow_depth, stow_pad_thickness]);
        translate([stow_width / 2, stow_depth / 2, -grid_eps])
            cylinder(d=magnet_pocket_diameter,
                h=stow_pad_thickness + 2 * grid_eps, $fn=magnet_facets);
    }
}
module carrier_pose(t) {
    translate([0, slider(t)[0], slider(t)[1]])
        rotate([carrier_angle(t), 0, 0]) children();
}
module dock_pad() {
    difference() {
        cube([dock_width, dock_depth, dock_pad_thickness]);
        translate([dock_width / 2, dock_depth / 2, -grid_eps])
            cylinder(d=magnet_pocket_diameter,
                h=dock_pad_thickness + 2 * grid_eps, $fn=magnet_facets);
    }
}
module assembly(t=deployment) {
    color("SteelBlue") maker_panel();
    if (show_hardware) color("Silver")
        hardware_set(1, slider(t), slider_hardware());
    color("DimGray") {
        for (side = [-1, 1])
            yz_prism(side * pad_lane - pad_width / 2,
                pad_width, rear_pad_yz());
        for (side = [-1, 1])
            translate([side * stow_lane - stow_width / 2,
                stow_y - stow_depth / 2,
                stow_top - stow_pad_thickness]) stow_pad();
        for (side = [-1, 1])
            translate([side * dock_lane - dock_width / 2,
                dock_y - dock_depth / 2, dock_top]) dock_pad();
    }
    for (side = [-1, 1]) {
        p = brace_tip(t);
        color("Silver") translate([side * brace_lane, fixed_b[0], fixed_b[1]])
            rotate([atan2(p[1] - fixed_b[1], p[0] - fixed_b[0]), 0, 0])
                brace();
        if (show_hardware) {
            color("Silver") hardware_set(side, fixed_b, brace_hardware());
        }
    }
    carrier_pose(t) {
        color("DarkSlateBlue") vesa_panel();
        if (show_hardware) for (side = [-1, 1]) color("Silver")
            hardware_set(side, [carrier_span, 0], brace_hardware());
        if (show_monitor) color([0.2, 0.65, 0.8, 0.25])
            translate([monitor_offset_x, monitor_center_y,
                plate_top + monitor_depth / 2])
                cube([monitor_width, monitor_height, monitor_depth],
                    center=true);
    }
}

// Basic fabrication guards; not a complete finite-sweep collision proof.
assert(grid_triangle >= 10 && grid_triangle <= 30
    && grid_rib >= 3 && grid_rib <= 5
    && grid_triangle > sqrt(3) * grid_rib,
    "Grid must retain >=3 mm ribs and positive triangular openings");
assert(grid_border >= 10 && grid_border <= 20
    && grid_margin >= 4 && grid_margin <= 8
    && mount_washer_diameter >= MOUNT_HOLE_DIAMETER
    && vesa_bearing_diameter >= 2 * vesa_bore,
    "Keep perimeter, outside-root margins and hardware bearing envelopes");
assert(min(panel_width, panel_height, plate_right - plate_left,
    plate_end - plate_start) > 2 * grid_border,
    "Border must leave a positive inset rectangle");
assert(deployment >= 0 && deployment <= 1, "deployment must be 0..1");
assert(metal_thickness >= 1 && metal_thickness <= 4, "Stock must be 1..4 mm");
assert(panel_depth >= 1 && panel_depth <= 3, "Panel must be 1..3 mm");
assert(monitor_width > 0 && monitor_height > 0 && monitor_depth > 0,
    "Monitor dimensions must be positive");
assert(vesa_plate_width >= 0, "Width request must be nonnegative");
assert(slot_radius * cos(180 / 48) > slider_bolt_radius
    && slider_bore * cos(180 / 48) > slider_bolt_radius
    && slider_washer_bore * cos(180 / 48) > slider_bolt_radius
    && slider_nut_bore * cos(180 / 48) > slider_bolt_radius
    && slider_lug_radius > slot_radius + 2,
    "M4 shaft must fit faceted slot, lug bores and hardware rings");
assert(slider_bolt_length == 45 && slider_thread_pitch == 0.7
    && slider_stack < slider_bolt_length
    && slider_protrusion + 0.00000001 >= 2 * slider_thread_pitch,
    "M4x45 stack must be <45 mm and leave at least two thread pitches");
assert(track_width > 0 && slider_running_gap >= 0.5
    && slider_lug_thickness >= 8 && slider_washer_thickness > 0
    && slider_nut_thickness >= 5,
    "Retain solid block, lugs, external washers, nyloc and running gaps");
// Nyloc is retention, NOT a motion lock. Snug-adjust only: structural
// torque would flex the carrier and clamp away the two running gaps.
assert(brace_length > carrier_span && branch_end > 10,
    "Keep monotonic slider branch away from toggle");
assert(deployed_angle == 90 && slider_end - slider_start > 100,
    "Require long front-to-rear travel and an exactly vertical monitor");
assert(slider_start == panel_front + slider_lug_radius
    && carrier_span == (fixed_b[0] - slider_start - 1) / 2
    && brace_length == carrier_span + 1
    && norm(slider(0) - [slider_start, slider_z]) < 0.00000001
    && norm(slider(1) - [slider_end, slider_z]) < 0.00000001,
    "Travel and D attachment must follow the flush-front closure");
assert(fixed_b[0] > panel_rear / 2
    && fixed_b[0] + pivot_radius < panel_rear - 2,
    "Brace anchors must be rearward and inside panel");
assert(fixed_b[0] - slider_start > pivot_radius + slider_head_radius + 0.5,
    "Leave a FRONT transverse screw insertion path past the brace feet");
assert(vesa_row_y - vesa_bore > carrier_span + 8
    && vesa_row_y >= plate_start + 10
    && plate_end <= monitor_top_y, "Row must fit carrier and monitor");
assert(plate_left >= monitor_offset_x - monitor_width / 2
    && plate_right <= monitor_offset_x + monitor_width / 2,
    "Carrier must fit offset monitor");
assert(track_front == panel_front && track_rear == panel_rear,
    "Housing must be flush with panel ends: no projection or shortening");
assert(track_ligament >= 3
    && slider_start - slot_radius - track_front >= track_ligament
    && track_rear - slider_end - slot_radius >= track_ligament
    && slider_z - slot_radius - panel_depth >= track_ligament
    && slider_z - pivot_radius > panel_depth
    && slider_z - slider_lug_radius > panel_depth,
    "Preserve slot ligaments and moving boss/panel clearance");
assert(slider_z + monitor_bottom_y > track_top + 0.5
    && plate_bottom > monitor_bottom_y
    && plate_bottom > pivot_radius && plate_thickness >= 3,
    "Screen, plate, pads and slotted housing need running clearance");
assert(stow_lane - stow_width / 2 > slider_hardware_reach,
    "Stow pedestals must be outside the slider hardware sweep");
assert(stow_lane - stow_width / 2 > brace_lane + metal_thickness / 2
    && -stow_lane - stow_width / 2 >= plate_left
    && stow_lane + stow_width / 2 <= plate_right,
    "Stow footprints must clear arms and fit entirely within the carrier");
assert(magnet_pocket_diameter * cos(180 / magnet_facets) > magnet_diameter
    && magnet_pocket_depth > magnet_thickness && magnet_thickness > 0
    && min(stow_width, stow_depth) >= magnet_pocket_diameter + 3.8
    && plate_thickness - magnet_pocket_depth >= 0.9 - 0.00000001
    && stow_pad_thickness > 0
    && stow_top - stow_pad_thickness - magnet_pocket_depth > panel_depth,
    "Magnet pockets need insertion clearance, side walls and blind floors");
assert(stow_margin >= 2
    && stow_y - stow_depth / 2 >= panel_front + 2
    && stow_y + stow_depth / 2 <= panel_rear - 2
    && stow_y - stow_depth / 2 >= slider_start + plate_start
    && stow_y + stow_depth / 2 <= slider_start + plate_end,
    "Stow pads must stay inside panel and contact the folded plate");
assert(stow_screen_gap >= 2
    && (stow_y - stow_depth / 2 >= pad_back[0] + stow_screen_gap
        || stow_y + stow_depth / 2 <= pad_front[0] - stow_screen_gap),
    "Stow pads must clear the deployed screen");
assert(clevis_outer() + head_thickness + 2 < panel_width / 2
    - RACK_RAIL_HEIGHT / 2 - MOUNT_HOLE_DIAMETER / 2,
    "Leave panel mounting-hole access");
assert(pad_front[0] > panel_rear / 3 && pad_back[0] <= panel_rear - 2
    && pad_front[0] >= panel_front + 2
    && pad_back[1] - pad_thickness > panel_depth,
    "Padded stops must fit above panel and inside rear edge");
assert(pad_lane - pad_width / 2 > slider_hardware_reach
    && pad_lane + pad_width / 2 < brace_lane - metal_thickness / 2,
    "Rear pads must clear slider hardware and low metal arms");
assert(dock_lane - dock_width / 2 > slider_hardware_reach + 1.5
    && dock_lane + dock_width / 2 < clevis_inner()
        - nut_thickness - bolt_extension - 1.5,
    "Dock lanes must clear the full slider and brace hardware envelopes");
assert(min(dock_width, dock_depth) >= magnet_pocket_diameter + 3
    && dock_stow_wall >= 1.5 && dock_pad_thickness == 0.5,
    "Inboard stow seats need >=1.5 mm walls and 0.5 mm cushions");
assert(dock_top - magnet_pocket_depth - panel_depth >= 1.5
    && dock_y + dock_depth / 2 < panel_rear - 2
    && dock_contact_z < pad_back[1]
    && -dock_lane - dock_width / 2 >= plate_left
    && dock_lane + dock_width / 2 <= plate_right,
    "Dock pedestals need pocket floors and must fit within the carrier");
assert(dock_fold_bottom > 0
    && dock_fold_bottom + magnet_pocket_depth < plate_bottom
    && dock_fold_top - dock_fold_bottom - magnet_pocket_depth >= 1.5
    && dock_fold_top - plate_bottom >= 2 && dock_fold_top < plate_top
    && dock_fold_start >= plate_start
    && min(plate_end, dock_fold_y + dock_depth / 2) - dock_fold_start >= 5
    && dock_fold_y + dock_depth / 2 <= monitor_top_y,
    "Folded dock seats need blind roofs and full-volume plate roots");

if (part == "assembly") {
    assembly();
} else if (part == "poses") {
    for (i = [0:1:2])
        translate([i * max(monitor_width + 30, panel_width + 30), 0, 0])
            assembly(i / 2);
} else if (part == "maker_panel") {
    maker_panel();
} else if (part == "vesa_panel") {
    vesa_panel();
} else if (part == "brace") {
    brace();
} else if (part == "brace_2d") {
    brace_2d();
} else if (part == "slider_bolt") {
    hardware_set(1, [0, 0], slider_bolt_hardware());
} else if (part == "slider_washer") {
    ring(slider_washer_radius, slider_washer_bore, slider_washer_thickness);
} else if (part == "slider_locknut") {
    hardware_set(1, [0, 0], slider_locknut_hardware());
} else if (part == "pivot_washer") {
    if (washer_thickness > 0)
        ring(head_radius, bore_radius, washer_thickness);
} else if (part == "rear_pad") {
    rear_pad();
} else if (part == "stow_pad") {
    stow_pad();
} else {
    assert(false, "Unknown part selector");
}

