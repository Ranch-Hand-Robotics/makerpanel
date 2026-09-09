// Captured-slider monitor mount. +Y = panel rear; +Z = up; axes parallel X.
// Carrier +Y is its top, +Z its display face: positive X rotation only.
// Two rear braces and ONE transverse M4x45 screw give one nominal DOF.
// Prototype, NOT load-rated. Support while moving AND deployed: no lock,
// counterbalance or transport latch. Rear pads stop over-opening only.
include <makerpanel/common.scad>
include <makerpanel/panel.scad>

/* [Customization] */
part = "assembly"; // [assembly, poses, maker_panel, vesa_panel, brace, brace_profile, slider_bolt, slider_washer, slider_locknut, pivot_washer, rear_pad, stow_pad]
metal_thickness = 1.5; // [1:0.5:4]
verticalUnits = 4; // [1:1:8]
horizontalPitch = 35; // [4:1:40]
deployment = 0; // [0:0.01:1]
show_monitor = true;
show_hardware = true;
monitor_width = 700;
monitor_height = 190;
monitor_depth = 15;
monitor_row_offset = 60;
monitor_offset_x = 70;
panel_depth = 3;
vesa_plate_width = 0;

/* [Hidden] */
module hidden() {}
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
washer_thickness = 1;
clevis_gap = metal_thickness + 2 * washer_thickness;
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
vesa_row_y = monitor_center_y + monitor_row_offset;
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
required_left = min(-brace_lane - clevis_gap / 2 - cheek_thickness - 2,
    monitor_offset_x - vesa_spacing / 2 - vesa_margin);
required_right = max(brace_lane + clevis_gap / 2 + cheek_thickness + 2,
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
stow_depth = 4;
stow_lane = 69;
stow_width = 8;
// Rear-edge setback preserves default Y65.5..69.5. The shorter folded
// plate footprint on 5U moves these stops forward, clear of the screen.
stow_margin = 19.4;
stow_rear_y = min(panel_rear, slider_start + plate_end)
    - stow_depth / 2 - stow_margin;
// If the rear candidate is not behind the standing screen, place the
// whole pad ahead of it. This also accommodates lower VESA row inputs.
stow_screen_gap = 2;
stow_y = stow_rear_y - stow_depth / 2 >= pad_back[0] + stow_screen_gap
    ? stow_rear_y
    : min(stow_rear_y, pad_front[0] - stow_depth / 2 - stow_screen_gap);
stow_top = slider_z + plate_bottom;
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

// Exact tables drive rendering AND source tests. Boxes: [name, XYZ lo/hi].
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
        stow_y + stow_depth / 2, stow_top - pad_thickness]]]);
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
        // Continue toward screen top (+Y), all the way to the plate edge.
        [x[1], plate_end, plate_bottom + 2]]
], [for (side = [-1, 1], cheek = [-1, 1]) let(x = cheek_x(side, cheek))
    ["D_riser", [x[0], carrier_span - 8, 0],
        [x[1], carrier_span + 8, plate_bottom + 2]]
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
    ["washer_i", brace_lane - metal_thickness / 2 - washer_thickness,
        brace_lane - metal_thickness / 2, head_radius, bore_radius],
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
    }
}
module vesa_panel() {
    difference() {
        union() {
            for (box = carrier_boxes()) bounds_box(box);
            for (p = carrier_rounds()) round_solid(p);
        }
        for (p = carrier_cuts()) round_solid(p);
        for (side = [-1, 1])
            translate([vesa_x(side), vesa_row_y, -1])
                cylinder(r=vesa_bore, h=plate_top + 2, $fn=48);
    }
    // Deliberately NO VESA bosses: monitor back is flush at plate_top.
}
module brace_profile() {
    difference() {
        hull() for (y = [0, brace_length])
            translate([0, y]) circle(r=link_radius, $fn=48);
        for (y = [0, brace_length])
            translate([0, y]) circle(r=bore_radius, $fn=48);
    }
}
module brace() {
    rotate([0, 90, 0]) linear_extrude(height=metal_thickness, center=true)
        brace_profile();
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
    cube([stow_width, stow_depth, pad_thickness]);
}
module carrier_pose(t) {
    translate([0, slider(t)[0], slider(t)[1]])
        rotate([carrier_angle(t), 0, 0]) children();
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
                stow_top - pad_thickness]) stow_pad();
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

// Basic fabrication guards. External tests check the complete finite sweep.
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
} else if (part == "brace_profile") {
    brace_profile();
} else if (part == "slider_bolt") {
    hardware_set(1, [0, 0], slider_bolt_hardware());
} else if (part == "slider_washer") {
    ring(slider_washer_radius, slider_washer_bore, slider_washer_thickness);
} else if (part == "slider_locknut") {
    hardware_set(1, [0, 0], slider_locknut_hardware());
} else if (part == "pivot_washer") {
    ring(head_radius, bore_radius, washer_thickness);
} else if (part == "rear_pad") {
    rear_pad();
} else if (part == "stow_pad") {
    stow_pad();
} else {
    assert(false, "Unknown part selector");
}

