// Hook-rack monitor. +Y = rear, -Y = front, +Z = up.
// Prototype, not load-rated. Unload, lift rearward, then reseat both bolts.
include <makerpanel/common.scad>
include <makerpanel/panel.scad>
use <examples/vent_panel/IsoGridScad/isogrid.scad>

/* [Customization] */
part = "assembly"; // [assembly, makerpanel, vesa_panel, brace, brace_2d]
verticalUnits = 2; // [1:1:8]
horizontalPitch = 35; // [4:1:80]
// Select row zero to fold flat; up_angle sets only the last rack position.
dock_row = 0; // [0:1:3]
up_angle = 90; // [60:1:90]
// Positions along each rack; each docking set has 2 parallel racks.
rack_rows = 4; // [2:1:4]
show_monitor = true;
show_hardware = true;
monitor_width = 700;
monitor_height = 190;
monitor_depth = 15;
// Measured along the monitor back from its actual bottom to screw centers.
monitor_row_offset = 90;
monitor_offset_x = 50;
// Extra clearance beneath the mechanism; rack and pivots rise together.
monitor_offset_z = 0; // [0:1:50]
panel_depth = 4.2;
face_thickness = 4;
vesa_plate_width = 0; // Zero preserves the panel-root and screw-pad span.
base_isogrid = true;
face_isogrid = true;
grid_triangle = 25; // [10:1:30]
grid_hole = 5; // [0:0.5:10]
grid_rib = 3; // [3:0.5:5]
grid_border = 10; // [10:1:20]
grid_margin = 4; // [4:0.5:8]
mount_washer_diameter = 7;
vesa_bearing_diameter = 9;
// Use M4x20 screws and locknuts; do not clamp away the running clearance.
arm_length = 30;
arm_attach_row = 24;
metal_thickness = 4;
pivot_diameter = 4.4;
pivot_radius = 4.5;
tab_thickness = 4;
pivot_clearance = 0.3;
fold_clearance = 1;
// M4 under-head length includes both tabs, locknut and projecting thread.
// Leave tabs unpinched; use a smooth bearing span through the racks.
docking_bolt_length = 40; // [35:1:40]
// Center-to-center distance between the two complete docking sets.
docking_set_spacing = 56;
rack_thickness = 6;
rack_clearance = 0.6;
hook_wall = 4;
tooth_web = 4;
rack_floor = 1.5;
bolt_floor_clearance = 0.5;
// Openings lean rearward; the lip blocks a straight upward escape.
hook_entry_offset = 8;
hook_rise = 2.5;
dock_drop = 9.5;

/* [Hidden] */
module hidden() {}
eps = 0.01;
facets = 64;
panel_width = hp_to_mm(horizontalPitch);
panel_height = u_to_mm(verticalUnits);
panel_front = -panel_height / 2;
panel_rear = panel_height / 2;
vesa_spacing = 75;
vesa_diameter = 4.5;
mount_pad_radius = max(8, mount_washer_diameter / 2 + grid_margin);
vesa_pad_radius = max(8, vesa_bearing_diameter / 2 + grid_margin);
face_height = monitor_row_offset + max(grid_border, vesa_pad_radius + 2);
required_left = min(-panel_width / 2 + grid_border + grid_margin,
    monitor_offset_x - vesa_spacing / 2 - vesa_pad_radius - 2);
required_right = max(panel_width / 2 - grid_border - grid_margin,
    monitor_offset_x + vesa_spacing / 2 + vesa_pad_radius + 2);
face_extra = max(0, vesa_plate_width - required_right + required_left) / 2;
face_left = required_left - face_extra;
face_right = required_right + face_extra;
face_width = face_right - face_left;
arm_lane = panel_width / 2 - grid_border - grid_margin - 12;
clevis_gap = metal_thickness + 2 * pivot_clearance;
clevis_width = clevis_gap + 2 * tab_thickness;
bolt_diameter = 4;
docking_nut_length = 5;
docking_thread_extra = 2;
bolt_tab_lane = (docking_bolt_length - docking_nut_length
    - docking_thread_extra - tab_thickness) / 2;
rack_lane = bolt_tab_lane - tab_thickness / 2
    - pivot_clearance - rack_thickness / 2;
seat_radius = (bolt_diameter + rack_clearance) / 2;
bolt_row = -4;
base_pivot_z = panel_depth + monitor_offset_z
    + pivot_radius + fold_clearance;
seat_z = panel_depth + monitor_offset_z
    + max(seat_radius + rack_floor, pivot_radius + bolt_floor_clearance);
// Lower the cross-bolt without lowering the folded links or plate.
bolt_drop = dock_drop + max(0, base_pivot_z - seat_z);
rack_top = seat_z + hook_rise;
// Preserve the original throat slope when trimming the hook tops.
release_rise = max(7.8, hook_rise + seat_radius + 0.5);
stow_origin_z = seat_z + bolt_drop;
stow_origin_y = panel_front + seat_radius + hook_wall + 0.5 - bolt_row;
base_pivot_y = stow_origin_y + arm_attach_row
    + sqrt(pow(arm_length, 2)
        - pow(stow_origin_z - dock_drop - base_pivot_z, 2));
stow_radius = 4;
// Place folded feet in the clear center gap between the docking sets.
stow_lane = (docking_set_spacing / 2 - rack_lane - rack_thickness / 2) / 2;
stow_base_y = min(panel_rear - grid_border,
    stow_origin_y + face_height - stow_radius - grid_margin);
stow_face_y = stow_base_y - stow_origin_y;
stow_drop = stow_origin_z - panel_depth;

function vesa_x(side) = monitor_offset_x + side * vesa_spacing / 2;
function origin_z(angle) = seat_z - bolt_row * sin(angle)
    + bolt_drop * cos(angle);
function origin_y(angle) = base_pivot_y - arm_attach_row * cos(angle)
    - dock_drop * sin(angle)
    - sqrt(pow(arm_length, 2)
        - pow(origin_z(angle) + arm_attach_row * sin(angle)
            - dock_drop * cos(angle) - base_pivot_z, 2));
function front_y(angle) = origin_y(angle) + bolt_row * cos(angle)
    + bolt_drop * sin(angle);
function rack_count() = min(rack_rows, max(2, 1 + floor(
    (front_y(up_angle) - front_y(0)) / ((2 * seat_radius + tooth_web)
        * sqrt(1 + pow(hook_entry_offset / release_rise, 2))))));
function row_y(row) = front_y(0)
    + row * (front_y(up_angle) - front_y(0)) / (rack_count() - 1);
function solve_angle(y, lo=0, hi=up_angle, steps=40) =
    steps == 0 ? (lo + hi) / 2 : let(mid = (lo + hi) / 2)
    front_y(mid) < y ? solve_angle(y, mid, hi, steps - 1)
        : solve_angle(y, lo, mid, steps - 1);
function row_angle(row) = row == 0 ? 0
    : row >= rack_count() - 1 ? up_angle : solve_angle(row_y(row));
function face_origin(row) = [0,
    origin_y(row_angle(row)), origin_z(row_angle(row))];
function arm_tip(row) = [origin_y(row_angle(row))
    + arm_attach_row * cos(row_angle(row)) + dock_drop * sin(row_angle(row)),
    origin_z(row_angle(row)) + arm_attach_row * sin(row_angle(row))
        - dock_drop * cos(row_angle(row))];
function cheek_x(lane, edge) = lane + edge * (clevis_gap + tab_thickness) / 2;
function docking_centers() = [-docking_set_spacing / 2,
    docking_set_spacing / 2];
function rack_lanes() = [for (center = docking_centers(), side = [-1, 1])
    center + side * rack_lane];
function mount_centers() = [for (sx = [-1, 1], sy = [-1, 1])
    [sx * (panel_width / 2 - RACK_RAIL_HEIGHT / 2),
     sy * (panel_height / 2 - RACK_RAIL_HEIGHT / 2)]];

module face_pose(row=dock_row) {
    translate(face_origin(row)) rotate([row_angle(row), 0, 0]) children();
}

module rectangle(lo, hi) {
    translate(lo) square(hi - lo);
}

module bearing_pad(p, radius) {
    translate(p) circle(r=radius / cos(180 / facets), $fn=facets);
}

module axis_cylinder(d, length) {
    rotate([0, 90, 0]) cylinder(d=d, h=length, center=true, $fn=facets);
}

// IsoGrid returns positive ribs; subtract only their complement.
module grid_voids(lo, hi) {
    difference() {
        rectangle(lo + [grid_border, grid_border],
            hi - [grid_border, grid_border]);
        translate((lo + hi) / 2)
            isogrid_rect(hi[0] - lo[0], hi[1] - lo[1],
                triangle_size=grid_triangle, thickness=grid_rib,
                extrude=0, hole_size=grid_hole,
                top_chamfer=0, bottom_chamfer=0);
        children();
    }
}

module base_keepouts() {
    for (p = mount_centers()) bearing_pad(p, mount_pad_radius);
    for (x = rack_lanes())
        rectangle([x - rack_thickness / 2 - grid_margin,
            row_y(0) - seat_radius - hook_wall],
            [x + rack_thickness / 2 + grid_margin,
            row_y(rack_count() - 1) + hook_entry_offset
                + seat_radius + hook_wall]);
    for (side = [-1, 1]) {
        bearing_pad([side * stow_lane, stow_base_y],
            stow_radius + grid_margin);
        rectangle([side * arm_lane - clevis_width / 2 - grid_margin,
            base_pivot_y - pivot_radius - grid_margin],
            [side * arm_lane + clevis_width / 2 + grid_margin,
            base_pivot_y + pivot_radius + grid_margin]);
    }
}

module face_keepouts() {
    for (center = docking_centers())
        rectangle([center - bolt_tab_lane - tab_thickness - grid_margin, 0],
            [center + bolt_tab_lane + tab_thickness + grid_margin, 12]);
    rectangle([face_left, monitor_row_offset - vesa_pad_radius],
        [face_right, monitor_row_offset + vesa_pad_radius]);
    rectangle([face_left, arm_attach_row - pivot_radius - grid_margin],
        [face_right, arm_attach_row + pivot_radius + grid_margin]);
    for (side = [-1, 1]) {
        bearing_pad([vesa_x(side), monitor_row_offset], vesa_pad_radius);
        rectangle([side * arm_lane - clevis_width / 2 - grid_margin, 0],
            [side * arm_lane + clevis_width / 2 + grid_margin, face_height]);
        bearing_pad([side * stow_lane, stow_face_y],
            stow_radius + grid_margin);
    }
}

module base_skin() {
    difference() {
        makerpanel(horizontalPitch, verticalUnits, thickness=panel_depth,
            chamfer_start=1.2);
        if (base_isogrid) translate([0, 0, -eps])
            linear_extrude(height=panel_depth + 2 * eps)
                grid_voids([-panel_width / 2, panel_front],
                    [panel_width / 2, panel_rear]) base_keepouts();
    }
}

module flat_face() {
    face_center = [(face_left + face_right) / 2, face_height / 2, 0];
    translate([0, 0, -face_thickness]) translate(face_center)
        panel_extrude(size=[face_width, face_height],
            thickness=face_thickness, chamfer_start=1.2)
            translate(-face_center) difference() {
                rectangle([face_left, 0], [face_right, face_height]);
                if (face_isogrid) grid_voids([face_left, 0],
                    [face_right, face_height]) face_keepouts();
            }
}

module base_tabs() {
    for (side = [-1, 1], edge = [-1, 1]) {
        x = cheek_x(side * arm_lane, edge);
        difference() {
            hull() {
                translate([x, base_pivot_y, base_pivot_z])
                    axis_cylinder(2 * pivot_radius, tab_thickness);
                translate([x - tab_thickness / 2,
                    base_pivot_y - pivot_radius, 0])
                    cube([tab_thickness, 2 * pivot_radius, panel_depth]);
            }
            translate([x, base_pivot_y, base_pivot_z])
                axis_cylinder(pivot_diameter, tab_thickness + 2 * eps);
        }
    }
}

module vesa_tabs() {
    for (side = [-1, 1], edge = [-1, 1]) {
        x = cheek_x(side * arm_lane, edge);
        difference() {
            hull() {
                translate([x, arm_attach_row, -dock_drop])
                    axis_cylinder(2 * pivot_radius, tab_thickness);
                translate([x - tab_thickness / 2,
                    arm_attach_row - pivot_radius, -face_thickness - 1])
                    cube([tab_thickness, 2 * pivot_radius, 2]);
            }
            translate([x, arm_attach_row, -dock_drop])
                axis_cylinder(pivot_diameter, tab_thickness + 2 * eps);
        }
    }
}

module docking_tabs() {
    for (center = docking_centers(), side = [-1, 1]) {
        x = center + side * bolt_tab_lane;
        difference() {
            hull() {
                translate([x, bolt_row, -bolt_drop])
                    axis_cylinder(2 * pivot_radius, tab_thickness);
                translate([x - tab_thickness / 2, 0, -face_thickness - 1])
                    cube([tab_thickness, 10, 2]);
            }
            translate([x, bolt_row, -bolt_drop])
                axis_cylinder(pivot_diameter, tab_thickness + 2 * eps);
        }
    }
}

// Each side-by-side set has two racks aligned beneath its own cross-bolt.
module hook_racks() {
    for (x = rack_lanes()) difference() {
        translate([x - rack_thickness / 2,
            row_y(0) - seat_radius - hook_wall, 0])
            cube([rack_thickness,
                row_y(rack_count() - 1) - row_y(0) + hook_entry_offset
                    + 2 * (seat_radius + hook_wall), rack_top]);
        for (row = [0:1:rack_count() - 1]) hull() {
            translate([x, row_y(row), seat_z])
                axis_cylinder(2 * seat_radius, rack_thickness + 2 * eps);
            translate([x, row_y(row) + hook_entry_offset,
                seat_z + release_rise])
                axis_cylinder(2 * seat_radius, rack_thickness + 2 * eps);
        }
    }
}

module stow_feet() {
    for (side = [-1, 1])
        translate([side * stow_lane, stow_face_y, -stow_drop])
            cylinder(r=stow_radius,
                h=stow_drop - face_thickness + 1, $fn=facets);
}

module maker_panel() {
    difference() {
        union() {
            base_skin();
            base_tabs();
            hook_racks();
        }
        for (p = mount_centers()) translate([p[0], p[1], -eps])
            cylinder(d=MOUNT_HOLE_DIAMETER,
                h=panel_depth + 2 * eps, $fn=facets);
    }
}

module vesa_panel() {
    difference() {
        union() {
            flat_face();
            vesa_tabs();
            docking_tabs();
            stow_feet();
        }
        for (side = [-1, 1])
            translate([vesa_x(side), monitor_row_offset,
                -face_thickness - eps])
                cylinder(d=vesa_diameter,
                    h=face_thickness + 2 * eps, $fn=facets);
    }
}

module brace_2d() {
    difference() {
        hull() for (y = [0, arm_length])
            translate([0, y]) circle(r=pivot_radius, $fn=facets);
        for (y = [0, arm_length])
            translate([0, y]) circle(d=pivot_diameter, $fn=facets);
    }
}

module brace() {
    linear_extrude(height=metal_thickness) brace_2d();
}

module pivot_hardware(side, p) {
    x = side * arm_lane;
    translate([x + side * (clevis_width / 2 - 10), p[0], p[1]])
        axis_cylinder(4, 20);
    translate([x + side * (clevis_width / 2 + 2), p[0], p[1]])
        axis_cylinder(7, 4);
    translate([x - side * (clevis_width / 2 + 2.5), p[0], p[1]])
        rotate([0, 90, 0]) cylinder(d=7 / cos(30), h=5, center=true, $fn=6);
}

module docking_hardware() {
    outer = bolt_tab_lane + tab_thickness / 2;
    translate([outer - docking_bolt_length / 2, bolt_row, -bolt_drop])
        axis_cylinder(bolt_diameter, docking_bolt_length);
    translate([outer + 2, bolt_row, -bolt_drop]) axis_cylinder(7, 4);
    translate([-outer - docking_nut_length / 2, bolt_row, -bolt_drop])
        rotate([0, 90, 0]) cylinder(d=7 / cos(30),
            h=docking_nut_length, center=true, $fn=6);
}

module assembly() {
    color("SteelBlue") maker_panel();
    tip = arm_tip(dock_row);
    for (side = [-1, 1]) {
        color("Silver") translate([side * arm_lane,
            base_pivot_y, base_pivot_z])
            rotate([atan2(tip[1] - base_pivot_z,
                tip[0] - base_pivot_y), 0, 0]) rotate([0, 90, 0])
                linear_extrude(height=metal_thickness, center=true) brace_2d();
        if (show_hardware) color("Silver") {
            pivot_hardware(side, [base_pivot_y, base_pivot_z]);
            pivot_hardware(side, tip);
        }
    }
    face_pose() {
        color("LightSteelBlue") vesa_panel();
        if (show_hardware) color("Silver")
            for (side = [-1, 1])
                translate([side * docking_set_spacing / 2, 0, 0])
                    scale([side, 1, 1]) docking_hardware();
        if (show_monitor) color([0.2, 0.65, 0.8, 0.25])
            translate([monitor_offset_x - monitor_width / 2, 0, 0])
                cube([monitor_width, monitor_height, monitor_depth]);
    }
}

if (part == "assembly") {
    assembly();
} else if (part == "makerpanel") {
    maker_panel();
} else if (part == "vesa_panel") {
    vesa_panel();
} else if (part == "brace") {
    brace();
} else if (part == "brace_2d") {
    brace_2d();
}