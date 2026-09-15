// Fixed monitor wedge. +Y = panel rear, -Y = front, +Z = up.
// Two prints: removable tabbed VESA roof and slotted MakerPanel wedge.
// Prototype, not load-rated; verify the two-hole mount with the monitor maker.
include <makerpanel/common.scad>
include <makerpanel/panel.scad>
use <examples/vent_panel/IsoGridScad/isogrid.scad>

/* [Customization] */
part = "assembly"; // [assembly, makerpanel, vesa_panel]
verticalUnits = 2; // [1:1:8]
horizontalPitch = 35; // [4:1:80]
// Fixed fabrication angle from horizontal, not an articulation control.
monitor_angle = 15; // [15:1:30]
show_monitor = true;
monitor_width = 700;
monitor_height = 190;
monitor_depth = 15;
// Distance along the monitor back from its actual bottom to screw centers.
monitor_row_offset = 90;
monitor_offset_x = 70;
// Vertical clearance from MakerPanel top to the lowest support-lip underside.
monitor_offset_z = 0; // [0:1:50]
panel_depth = 3;
face_thickness = 4;
vesa_plate_width = 0; // Zero uses the minimum panel-root and screw-pad span.
wall_thickness = 4;
base_isogrid = true;
face_isogrid = true;
grid_triangle = 25; // [10:1:30]
grid_hole = 5; // [0:0.5:10]
grid_rib = 3; // [3:0.5:5]
grid_border = 10; // [10:1:20]
grid_margin = 4; // [4:0.5:8]
mount_washer_diameter = 7;
vesa_bearing_diameter = 9;
// Rearward clearance envelope for screw heads and driver shafts.
driver_diameter = 13;
// Four drop-in tabs, locked from outside with screws for plastic.
tab_thickness = 11;
tab_length = 12;
tab_depth = 8;
tab_clearance = 0.3;
socket_wall = 2;
// McMaster-Carr 95893A189; adapted from cyberdeck bottom-skin/frame holes.
screw_hole_diameter = 2.5;
screw_hole_taper_depth = 1.8;
screw_hole_thread_depth = 7;
screw_head_diameter = 5.25;
side_screw_thread_clearance = 0.25; // [0:0.05:1]
side_screw_head_clearance = 0.2; // [0:0.05:1]
side_screw_head_recess_extra = 0.4; // [0:0.05:2]
// Preview only: lift the plate and monitor to show the tab/slot interface.
assembly_lift = 0; // [0:1:60]

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
// The front-facing bottom corner lies exactly in the panel front plane.
// Lift the complete plate so its lowest underside, not the monitor back,
// is at panel top + offset. Preserve the full plate thickness at the lip.
face_origin_y = panel_front + monitor_depth * sin(monitor_angle);
lip_bottom_z = panel_depth + monitor_offset_z;
face_origin_z = lip_bottom_z + face_thickness * cos(monitor_angle);
face_height = monitor_row_offset + max(grid_border, vesa_pad_radius + 2);
required_left = min(-panel_width / 2 + grid_border + grid_margin,
    monitor_offset_x - vesa_spacing / 2 - vesa_pad_radius - 2);
required_right = max(panel_width / 2 - grid_border - grid_margin,
    monitor_offset_x + vesa_spacing / 2 + vesa_pad_radius + 2);
face_extra = max(0, vesa_plate_width - required_right + required_left) / 2;
face_left = required_left - face_extra;
face_right = required_right + face_extra;
face_width = face_right - face_left;
// Only the thin VESA face may overhang; all walls stay on the MakerPanel.
wedge_left = max(face_left, -panel_width / 2 + grid_border + grid_margin);
wedge_right = min(face_right, panel_width / 2 - grid_border - grid_margin);
wedge_width = wedge_right - wedge_left;
// Separate parts seat on the face underside, without overlapping solids.
wall_front_y = face_origin_y + face_thickness * sin(monitor_angle);
wall_front_z = lip_bottom_z;
face_rear_y = face_origin_y + face_height * cos(monitor_angle)
    + face_thickness * sin(monitor_angle);
face_rear_z = lip_bottom_z + face_height * sin(monitor_angle);
wedge_rear_y = min(face_rear_y, panel_rear - grid_border);
// If a short panel clips the rear wall, keep it on the original roof slope.
wedge_top_z = wall_front_z + (face_rear_z - wall_front_z)
    * (wedge_rear_y - wall_front_y) / (face_rear_y - wall_front_y);
wall_profile = [
    [wall_front_y, 0],
    [wedge_rear_y, 0],
    [wedge_rear_y, wedge_top_z],
    [wall_front_y, wall_front_z]
];
// Clear the complete floor INSIDE the walls, including its IsoGrid ribs.
// Only perimeter roots and four localized tab sockets remain underneath.
cavity_left = wedge_left + wall_thickness;
cavity_right = wedge_right - wall_thickness;
cavity_front = wall_front_y + wall_thickness;
cavity_rear = wedge_rear_y - wall_thickness;
// Long enough to clear the complete structure, including enlarged panels.
driver_reach = panel_height + monitor_height + face_height + face_origin_z;
tab_rows = [cavity_front + (cavity_rear - cavity_front) * 0.58,
    cavity_front + (cavity_rear - cavity_front) * 0.85];
socket_width = tab_thickness + 2 * tab_clearance + socket_wall;
// Match cyberdeck_screw_holes_perimeter: straight receiving bore.
side_pilot_depth = max(0, screw_hole_taper_depth)
    + max(0, screw_hole_thread_depth);
side_clearance_d = screw_hole_diameter + side_screw_thread_clearance;
side_head_d = screw_head_diameter + side_screw_head_clearance;
// Match bottom_skin_screw_holes_3d: depth-driven cone, limited to wall.
side_taper_h = min(max(0, screw_hole_taper_depth
    + side_screw_head_recess_extra), max(0, wall_thickness));

function roof_z(y) = wall_front_z + (y - wall_front_y)
    * sin(monitor_angle) / cos(monitor_angle);
function tab_x(side) = side < 0 ? cavity_left + tab_clearance
    : cavity_right - tab_clearance - tab_thickness;
function socket_x(side) = side < 0 ? cavity_left - eps
    : cavity_right - socket_width;
function tab_bottom(y) = roof_z(y - tab_length / 2) - tab_depth;
function side_screw_z(y) = tab_bottom(y) + tab_depth / 2;
function vesa_x(side) = monitor_offset_x + side * vesa_spacing / 2;
function face_world(p) = [p[0],
    face_origin_y + p[1] * cos(monitor_angle) - p[2] * sin(monitor_angle),
    face_origin_z + p[1] * sin(monitor_angle) + p[2] * cos(monitor_angle)];
function mount_centers() = [for (sx = [-1, 1], sy = [-1, 1])
    [sx * (panel_width / 2 - RACK_RAIL_HEIGHT / 2),
     sy * (panel_height / 2 - RACK_RAIL_HEIGHT / 2)]];

module face_pose() {
    translate([0, face_origin_y, face_origin_z])
        rotate([monitor_angle, 0, 0]) children();
}

module rectangle(lo, hi) {
    translate(lo) square(hi - lo);
}

module bearing_pad(p, radius) {
    translate(p) circle(r=radius / cos(180 / facets), $fn=facets);
}

// Library returns positive ribs. Subtract their complement from each skin.
// children() are solid root/bearing keepouts in the skin's own 2D plane.
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
    // Perimeter-wall roots, not strips through the open cavity.
    for (x = [wedge_left, cavity_right])
        rectangle([x - grid_margin, wall_front_y - grid_margin],
            [x + wall_thickness + grid_margin, wedge_rear_y + grid_margin]);
    rectangle([wedge_left - grid_margin, cavity_rear - grid_margin],
        [wedge_right + grid_margin, wedge_rear_y + grid_margin]);
    // Front wall stays rooted on the base even when the lip is raised.
    rectangle([wedge_left - grid_margin, wall_front_y - grid_margin],
        [wedge_right + grid_margin, cavity_front + grid_margin]);
}

module face_keepouts() {
    for (side = [-1, 1])
        bearing_pad([vesa_x(side), monitor_row_offset], vesa_pad_radius);
    for (x = [wedge_left, cavity_right])
        rectangle([x - grid_margin, 0],
            [x + wall_thickness + grid_margin, face_height]);
    rectangle([wedge_left, 0], [wedge_right,
        wall_thickness / cos(monitor_angle) + grid_margin]);
    // Project the entire rear wall onto the face, including shortened bays.
    rear_row = (wedge_rear_y - face_origin_y) * cos(monitor_angle)
        + (wedge_top_z - face_origin_z) * sin(monitor_angle);
    rectangle([wedge_left, rear_row
        - wall_thickness / cos(monitor_angle) - grid_margin],
        [wedge_right, rear_row + grid_margin]);
    // Carry both offset screws into the perimeter walls.
    rectangle([face_left, monitor_row_offset - vesa_pad_radius],
        [face_right, monitor_row_offset + vesa_pad_radius]);
    // Solid tab roots on the underside; never attach to isolated grid ribs.
    for (side = [-1, 1], y = tab_rows) {
        row = (y - wall_front_y) / cos(monitor_angle);
        rectangle([tab_x(side) - grid_margin,
            row - tab_length / cos(monitor_angle) / 2 - grid_margin],
            [tab_x(side) + tab_thickness + grid_margin,
            row + tab_length / cos(monitor_angle) / 2 + grid_margin]);
    }
}

module base_skin() {
    difference() {
        makerpanel(horizontalPitch, verticalUnits, thickness=panel_depth,
            chamfer_start=1.2);
        // Independent of base_isogrid: there is NEVER a floor in the cavity.
        translate([cavity_left, cavity_front, -eps])
            cube([cavity_right - cavity_left, cavity_rear - cavity_front,
                panel_depth + 2 * eps]);
        if (base_isogrid) translate([0, 0, -eps])
            linear_extrude(height=panel_depth + 2 * eps)
                grid_voids([-panel_width / 2, panel_front],
                    [panel_width / 2, panel_rear]) base_keepouts();
    }
}

module inclined_face() {
    face_center = [(face_left + face_right) / 2, face_height / 2, 0];
    // Center only for the bevel envelope; keep local Z=-face_thickness..0.
    face_pose() translate([0, 0, -face_thickness])
        translate(face_center)
            panel_extrude(size=[face_width, face_height],
                thickness=face_thickness, chamfer_start=1.2)
                translate(-face_center)
                    difference() {
                        rectangle([face_left, 0], [face_right, face_height]);
                        if (face_isogrid)
                            grid_voids([face_left, 0],
                                [face_right, face_height]) face_keepouts();
                    }
}

module wedge_prism(x, width) {
    translate([x, 0, 0]) multmatrix([
        [0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]])
        linear_extrude(height=width) polygon(wall_profile);
}

module wedge_walls() {
    // Closed side skins inside the panel: the overhang is only a thin face.
    for (x = [wedge_left, cavity_right]) wedge_prism(x, wall_thickness);
    // Close the raised front without adding anything under the overhang.
    intersection() {
        wedge_prism(wedge_left, wedge_width);
        translate([wedge_left, wall_front_y, 0])
            cube([wedge_width, wall_thickness, wedge_top_z]);
    }
    // Clip the rear wall to the same roof slope to avoid monitor intrusion.
    intersection() {
        wedge_prism(wedge_left, wedge_width);
        translate([wedge_left, cavity_rear, 0])
            cube([wedge_width, wall_thickness, wedge_top_z]);
    }
}

module tab_sockets() {
    // Local pockets attached to side walls, not crossbars or a cavity floor.
    for (side = [-1, 1], y = tab_rows) intersection() {
        wedge_prism(socket_x(side), socket_width + eps);
        translate([socket_x(side),
            y - tab_length / 2 - tab_clearance - socket_wall, 0])
            cube([socket_width + eps,
                tab_length + 2 * (tab_clearance + socket_wall),
                driver_reach]);
    }
}

module tab_slots() {
    // Open upward for straight vertical insertion; floor has end clearance.
    for (side = [-1, 1], y = tab_rows)
        translate([tab_x(side) - tab_clearance,
            y - tab_length / 2 - tab_clearance,
            tab_bottom(y) - tab_clearance])
            cube([tab_thickness + 2 * tab_clearance,
                tab_length + 2 * tab_clearance, driver_reach]);
}

module side_screw_pose(side, y, inset=0) {
    // Local +Z points INWARD from either outside wall face.
    translate([side < 0 ? wedge_left + inset : wedge_right - inset,
        y, side_screw_z(y)]) rotate([0, -side * 90, 0]) children();
}

module side_wall_screw_holes() {
    // Adapted from cyberdeck bottom_skin_screw_holes_3d, rotated sideways.
    // Clearance belongs only in the wedge wall, never in the receiving tab.
    for (side = [-1, 1], y = tab_rows)
        side_screw_pose(side, y) {
            translate([0, 0, -eps]) cylinder(d=side_clearance_d,
                h=wall_thickness + 2 * eps, $fn=32);
            if (side_taper_h > eps) {
                translate([0, 0, -eps])
                    cylinder(d=side_head_d, h=eps, $fn=32);
                cylinder(d1=side_head_d, d2=side_clearance_d,
                    h=side_taper_h, $fn=32);
            }
        }
}

module side_tab_pilots() {
    // Blind 2.5mm receiving holes; no nuts, inserts, or modeled threads.
    for (side = [-1, 1], y = tab_rows)
        side_screw_pose(side, y, wall_thickness + tab_clearance)
            translate([0, 0, -eps]) cylinder(d=screw_hole_diameter,
                h=side_pilot_depth + eps, $fn=32);
}

module vesa_tabs() {
    for (side = [-1, 1], y = tab_rows) {
        lo = y - tab_length / 2;
        hi = y + tab_length / 2;
        translate([tab_x(side), 0, 0]) multmatrix([
            [0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]])
            linear_extrude(height=tab_thickness) polygon([
                [lo, tab_bottom(y)], [hi, tab_bottom(y)],
                [hi, roof_z(hi) + 1], [lo, roof_z(lo) + 1]]);
    }
}

module vesa_panel() {
    difference() {
        union() {
            inclined_face();
            vesa_tabs();
        }
        screw_paths();
        side_tab_pilots();
    }
}

module screw_paths() {
    face_pose() for (side = [-1, 1]) {
        // Through the supporting angle, perpendicular to the monitor back.
        translate([vesa_x(side), monitor_row_offset, -face_thickness - eps])
            cylinder(d=vesa_diameter, h=face_thickness + 2 * eps, $fn=facets);
        // Keep the entire rearward tool path clear, even for offset presets.
        translate([vesa_x(side), monitor_row_offset,
            -face_thickness - driver_reach])
            cylinder(d=driver_diameter, h=driver_reach, $fn=facets);
    }
}

module maker_panel() {
    difference() {
        intersection() {
            union() {
                base_skin();
                wedge_walls();
                tab_sockets();
            }
            // Keep the base and socket undersides on the panel datum.
            translate([-driver_reach, -driver_reach, 0])
                cube([2 * driver_reach, 2 * driver_reach, driver_reach]);
        }
        tab_slots();
        side_wall_screw_holes();
        screw_paths();
        // Re-cut after union: no support or root can fill a panel bore.
        for (p = mount_centers()) translate([p[0], p[1], -eps])
            cylinder(d=MOUNT_HOLE_DIAMETER,
                h=panel_depth + 2 * eps, $fn=32);
    }
}

module assembly() {
    color("SteelBlue") maker_panel();
    translate([0, 0, assembly_lift]) {
        color("LightSteelBlue") vesa_panel();
        if (show_monitor) color([0.2, 0.65, 0.8, 0.25]) face_pose()
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
}