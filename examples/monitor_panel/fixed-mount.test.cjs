// Source-derived analytic checks, not an OpenSCAD mesh or strength test.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');

const root = path.resolve(__dirname, '../..');
const raw = fs.readFileSync(path.join(__dirname, 'monitor.scad'), 'utf8');
const strip = text => text.replace(/\/\/[^\n]*|\/\*[\s\S]*?\*\//g, '');
const source = strip(raw);
const common = strip(fs.readFileSync(
    path.join(root, 'makerpanel/common.scad'), 'utf8'));
const near = (a, b) => assert.ok(Math.abs(a - b) < 1e-8, `${a} != ${b}`);

function dimensions(overrides = {}) {
    const c = vm.createContext({
        sin: a => Math.sin(a * Math.PI / 180),
        cos: a => Math.cos(a * Math.PI / 180),
        min: Math.min, max: Math.max,
    });
    // Sequential evaluation deliberately rejects forward references.
    function declarations(text, inputs = {}) {
        for (const [, name, expression] of text.matchAll(
            /^([A-Za-z_]\w*)\s*=\s*([^;]+);/gm)) {
            c[name] = Object.hasOwn(inputs, name) ? inputs[name]
                : vm.runInContext(`(${expression})`, c);
        }
    }
    declarations(common.split('function ')[0]);
    for (const name of ['hp_to_mm', 'u_to_mm']) {
        const [, args, expression] = common.match(new RegExp(
            `function ${name}\\(([^)]*)\\)\\s*=\\s*([^;]+);`));
        c[name] = vm.runInContext(`(${args}) => (${expression})`, c);
    }
    declarations(source.split('function ')[0], overrides);
    for (const name of ['roof_z', 'tab_x', 'socket_x', 'tab_bottom',
        'side_screw_z', 'vesa_x', 'face_world']) {
        const [, args, expression] = source.match(new RegExp(
            `function ${name}\\(([^)]*)\\)\\s*=\\s*([^;]+);`));
        c[name] = vm.runInContext(`(${args}) => (${expression})`, c);
    }
    return c;
}

function local(c, y, z) {
    const dy = y - c.face_origin_y, dz = z - c.face_origin_z;
    return [dy * c.cos(c.monitor_angle) + dz * c.sin(c.monitor_angle),
        -dy * c.sin(c.monitor_angle) + dz * c.cos(c.monitor_angle)];
}

test('default dimensions preserve the actual monitor and asymmetric row', () => {
    const c = dimensions();
    near(c.panel_width, 177.8); near(c.panel_height, 88.9);
    assert.equal(c.monitor_angle, 15);
    assert.equal(c.grid_triangle, 25);
    assert.equal(c.monitor_offset_z, 0);
    assert.equal(c.assembly_lift, 0);
    assert.equal(c.show_monitor, true);
    assert.match(raw, /monitor_angle = 15; \/\/ \[15:1:30\]/);
    assert.equal(c.monitor_width, 700); assert.equal(c.monitor_height, 190);
    assert.equal(c.monitor_depth, 15); assert.equal(c.monitor_row_offset, 90);
    near(c.vesa_x(-1), 32.5); near(c.vesa_x(1), 107.5);
    near(c.face_left, -74.9); near(c.face_right, 118);
    near(c.face_width, 192.9); near(c.face_height, 100.5);
    assert.equal(c.wall_thickness, 4);
    near(c.wedge_left, -74.9); near(c.wedge_right, 74.9);
    near(c.wedge_width, 149.8);
    near(c.cavity_left, -70.9); near(c.cavity_right, 70.9);
    near(c.cavity_front, c.wall_front_y + c.wall_thickness);
    near(c.cavity_rear, c.wedge_rear_y - 4);
    assert.equal(c.vesa_diameter, 4.5);
});

for (const angle of [15, 20, 30]) {
    for (const inputs of [{}, { monitor_offset_x: 0 },
        { monitor_offset_x: -70 },
        { horizontalPitch: 40, verticalUnits: 5, monitor_height: 250 },
        { verticalUnits: 4 },
        { monitor_offset_z: 1 },
        { monitor_offset_z: 10 },
        { monitor_offset_z: 50, verticalUnits: 4 },
        { vesa_plate_width: 220 },
        { base_isogrid: false, face_isogrid: false }]) {
        test(`fixed geometry ${angle} degrees ${JSON.stringify(inputs)}`, () => {
            const c = dimensions({ ...inputs, monitor_angle: angle });
            const front = c.face_world([c.monitor_offset_x, 0, c.monitor_depth]);
            const back = c.face_world([c.monitor_offset_x, 0, 0]);
            near(front[1], c.panel_front);
            near(back[2], c.panel_depth + c.monitor_offset_z
                + c.face_thickness * c.cos(angle));
            assert.ok(front[2] >= c.panel_depth - 1e-8);
            for (const y of [0, c.monitor_height]) {
                for (const z of [0, c.monitor_depth]) {
                    const p = c.face_world([0, y, z]);
                    assert.ok(p[1] >= c.panel_front - 1e-8);
                    assert.ok(p[2] >= c.panel_depth - 1e-8);
                }
            }
            assert.ok(c.face_height <= c.monitor_height);
            assert.ok(c.face_left >= c.monitor_offset_x - c.monitor_width / 2);
            assert.ok(c.face_right <= c.monitor_offset_x + c.monitor_width / 2);

            // Raised side skins have vertical front edges, not a triangle
            // interpolated from ground (which would detach at large offsets).
            const [a, b, d, e] = c.wall_profile;
            const area = (b[0] - a[0]) * (d[1] - a[1]) / 2;
            assert.ok(area > 0);
            near(a[1], 0); near(b[1], 0);
            near(e[0], a[0]); near(e[1], c.wall_front_z);
            assert.ok(e[1] >= c.panel_depth);
            assert.ok(b[0] < c.panel_rear);
            near(b[0], d[0]);
            assert.ok(c.cavity_right > c.cavity_left);
            assert.ok(c.cavity_rear > c.cavity_front);
            near(c.cavity_left - c.wedge_left, c.wall_thickness);
            near(c.wedge_right - c.cavity_right, c.wall_thickness);
            near(c.wedge_rear_y - c.cavity_rear, c.wall_thickness);
            assert.ok(c.wedge_left > -c.panel_width / 2);
            assert.ok(c.wedge_right < c.panel_width / 2);
            assert.ok(c.face_origin_y > c.panel_front);
            assert.ok(c.wedge_rear_y <= c.panel_rear - c.grid_border);
            assert.ok(c.face_left <= c.wedge_left);
            assert.ok(c.face_right >= c.wedge_right);

            // Separate wall roofs seat exactly on the inclined underside.
            for (const t of [0.1, 0.5, 0.9]) {
                const q = local(c, e[0] + t * (d[0] - e[0]),
                    e[1] + t * (d[1] - e[1]));
                assert.ok(q[0] > 0 && q[0] < c.face_height);
                near(q[1], -c.face_thickness);
            }
            // The rear wall uses the same roof and overlaps both sides.
            const ry = c.cavity_rear + c.wall_thickness / 2;
            const rz = c.wall_front_z + (c.wedge_top_z - c.wall_front_z)
                * (ry - c.wall_front_y) / (c.wedge_rear_y - c.wall_front_y);
            const roof = local(c, ry, rz);
            near(roof[1], -c.face_thickness);
            assert.ok(rz > c.panel_depth);
            // All four wall roots are entirely on the panel.
            assert.ok(c.wedge_width > 2 * c.wall_thickness);

            // Mounting-hole bearing circles cannot intersect the floor cut.
            for (const sx of [-1, 1]) for (const sy of [-1, 1]) {
                const x = sx * (c.panel_width / 2 - c.RACK_RAIL_HEIGHT / 2);
                const y = sy * (c.panel_height / 2 - c.RACK_RAIL_HEIGHT / 2);
                const dx = Math.max(c.cavity_left - x, 0, x - c.cavity_right);
                const dy = Math.max(c.cavity_front - y, 0, y - c.cavity_rear);
                assert.ok(Math.hypot(dx, dy) > c.mount_pad_radius);
            }
            // The complete untrimmed overhang stays above the clearance
            // plane; its lowest lip underside is exactly at that plane.
            near(c.face_world([c.face_right, 0, -c.face_thickness])[2],
                c.panel_depth + c.monitor_offset_z);
            for (const x of [c.face_left, c.face_right]) {
                for (const y of [0, c.face_height / 2, c.face_height]) {
                    for (const z of [-c.face_thickness, 0]) {
                        assert.ok(c.face_world([x, y, z])[2]
                            >= c.panel_depth + c.monitor_offset_z - 1e-8);
                    }
                }
            }
            // Lip is supported by grounded perimeter walls, not base contact.
            const toe = c.face_world([0, 0.1, -c.face_thickness / 2]);
            assert.ok(toe[1] > c.panel_front && toe[1] < c.panel_rear);
            assert.ok(toe[2] > c.panel_depth + c.monitor_offset_z);

            for (const side of [-1, 1]) {
                const x = c.vesa_x(side);
                assert.ok(x - c.vesa_pad_radius > c.face_left);
                assert.ok(x + c.vesa_pad_radius < c.face_right);
                const p = c.face_world([x, c.monitor_row_offset, 0]);
                const q = c.face_world([x, c.monitor_row_offset, -c.face_thickness]);
                near(Math.hypot(...p.map((v, i) => v - q[i])), c.face_thickness);
                near((p[1] - q[1]) * c.cos(angle)
                    + (p[2] - q[2]) * c.sin(angle), 0);
                // Drivers can be inside the cavity OR outside the wedge
                // under the thin overhang, but cannot intersect a side wall.
                for (const lo of [c.wedge_left, c.cavity_right]) {
                    assert.ok(x + c.driver_diameter / 2 <= lo + 1e-8
                        || x - c.driver_diameter / 2
                            >= lo + c.wall_thickness - 1e-8);
                }
                // At shallow angles drivers approach from below/rear.
                // The global cutter must reach through the panel underside.
                const t = q[2] / c.cos(angle);
                assert.ok(t > 0 && t < c.driver_reach);
                // Rear-wall crossings are opened by the global cutter.
                const rearT = (c.wedge_rear_y - q[1]) / c.sin(angle);
                assert.ok(Math.abs(rearT) < c.driver_reach);
                if (c.wedge_rear_y === c.face_rear_y) assert.ok(rearT > 0);
            }
        });
    }
}

test('actual cutters preserve roots and bores after the structural union', () => {
    assert.match(source, /linear_extrude\(height=width\) polygon\(wall_profile\)/);
    assert.match(source, /for \(x = \[wedge_left, cavity_right\]\) wedge_prism\(x, wall_thickness\)/);
    assert.match(source, /wedge_prism\(wedge_left, wedge_width\);\s*translate\(\[wedge_left, cavity_rear, 0\]\)/);
    assert.match(source, /wedge_prism\(wedge_left, wedge_width\);\s*translate\(\[wedge_left, wall_front_y, 0\]\)/);
    assert.match(source, /makerpanel\(horizontalPitch, verticalUnits,/);
    assert.match(source, /grid_voids\([\s\S]*?isogrid_rect\(/);
    assert.match(source, /hole_size=grid_hole/);
    assert.match(source, /base_keepouts\(\)[\s\S]*?mount_centers\(\)/);
    assert.match(source, /face_keepouts\(\)[\s\S]*?bearing_pad\(\[vesa_x/);
    assert.match(source, /monitor_row_offset - vesa_pad_radius/);
    assert.match(source, /intersection\(\)[\s\S]*?wedge_walls\(\);[\s\S]*?screw_paths\(\);/);
    assert.match(source, /translate\(\[-driver_reach, -driver_reach, 0\]\)/);
    assert.match(source, /h=face_thickness \+ 2 \* eps/);
    assert.match(source, /cylinder\(d=driver_diameter, h=driver_reach/);
    assert.match(source, /screw_paths\(\);[\s\S]*?cylinder\(d=MOUNT_HOLE_DIAMETER/);
    assert.doesNotMatch(source,
        /\b(?:deployment|slider|brace|magnet|clevis|gusset|open_gusset)\w*\b/);
});

test('floor opening is unconditional and cuts the base, not the roof', () => {
    const base = source.split('module base_skin() {')[1]
        .split('module inclined_face()')[0];
    const cutter = /translate\(\[cavity_left, cavity_front, -eps\]\)\s*cube\(\[cavity_right - cavity_left, cavity_rear - cavity_front,\s*panel_depth \+ 2 \* eps\]\);/;
    assert.match(base, cutter);
    assert.ok(base.indexOf('cavity_left') < base.indexOf('if (base_isogrid)'));
    assert.equal(source.match(cutter)[0], base.match(cutter)[0]);
    // No other internal solid remains below the roof: only skins and walls.
    const union = source.split('module maker_panel()')[1]
        .match(/union\(\)\s*\{([^}]+)\}/)[1].replace(/\s+/g, ' ').trim();
    assert.equal(union, 'base_skin(); wedge_walls(); tab_sockets();');
});

test('catalog selectors match the two-piece source outputs', () => {
    const catalog = JSON.parse(fs.readFileSync(path.join(root,
        'docs/gallery.json'), 'utf8')).panels.find(p => p.slug === 'monitor_panel');
    assert.deepEqual(catalog.scadParts,
        ['assembly', 'makerpanel', 'vesa_panel']);
    assert.equal(catalog.verticalUnits, 2);
    assert.equal(catalog.title, 'Fixed-Angle Monitor Mount');
});

test('wider VESA plates do not enlarge walls or the underside opening', () => {
    const initial = dimensions();
    const wider = dimensions({ vesa_plate_width: 260 });
    assert.ok(wider.face_width > initial.face_width);
    for (const key of ['wedge_left', 'wedge_right', 'wedge_width',
        'wedge_rear_y', 'cavity_left', 'cavity_right', 'cavity_rear']) {
        near(wider[key], initial[key]);
    }
    const walls = source.split('module wedge_walls() {')[1]
        .split('module screw_paths()')[0];
    assert.doesNotMatch(walls, /\bface_(?:left|right|width)\b/);
    assert.match(source, /for \(x = \[wedge_left, cavity_right\]\)\s*rectangle/);
    // Overhang uses the same beveled extrusion as the mounting face.
    const face = source.split('module inclined_face() {')[1]
        .split('module wedge_prism(')[0];
    assert.match(face, /panel_extrude\(size=\[face_width, face_height\],\s*thickness=face_thickness, chamfer_start=1\.2\)/);
    assert.match(face, /rectangle\(\[face_left, 0\], \[face_right, face_height\]\)/);
});

test('panel bevels preserve the asymmetric face datum and finished profile', () => {
    const face = source.split('module inclined_face() {')[1]
        .split('module wedge_prism(')[0];
    assert.match(source, /makerpanel\(horizontalPitch, verticalUnits,\s*thickness=panel_depth,\s*chamfer_start=1\.2\)/);
    assert.match(face, /face_pose\(\) translate\(\[0, 0, -face_thickness\]\)\s*translate\(face_center\)\s*panel_extrude/);
    assert.match(face, /translate\(-face_center\)\s*difference\(\)/);
    assert.match(face, /if \(face_isogrid\)\s*grid_voids\(/);
    assert.match(face, /face_keepouts\(\);/);
    assert.doesNotMatch(face, /linear_extrude|scale\(/);
    const centerExpression = face.match(/face_center\s*=\s*([^;]+);/)[1];
    for (const offset of [-70, 0, 70]) for (const width of [0, 260]) {
        for (const thickness of [1, 1.2, 3, 4, 6]) {
            const c = dimensions({ monitor_offset_x: offset,
                vesa_plate_width: width, face_thickness: thickness });
            const center = vm.runInContext(centerExpression, c);
            near(center[0] - c.face_width / 2, c.face_left);
            near(center[0] + c.face_width / 2, c.face_right);
            near(center[1] - c.face_height / 2, 0);
            near(center[1] + c.face_height / 2, c.face_height);
            near(center[2], 0);
            // Helper Z is measured from this plate's actual local underside.
            near(-thickness + center[2], -c.face_thickness);
            near(-thickness + center[2] + thickness, 0);
            const startZ = -thickness + 1.2;
            const bevel = Math.max(0, thickness - 1.2);
            near(bevel, Math.max(0, -startZ));
        }
    }
});

test('vertical offsets lift the full lip and wall roofs, not the panel', () => {
    for (const angle of [15, 30]) for (const height of [2, 4]) {
        const zero = dimensions({ monitor_angle: angle, verticalUnits: height });
        const raised = dimensions({ monitor_angle: angle, verticalUnits: height,
            monitor_offset_z: 12 });
        for (const key of ['face_origin_z', 'lip_bottom_z', 'wall_front_z',
            'wedge_top_z', 'face_rear_z']) near(raised[key] - zero[key], 12);
        for (const key of ['panel_depth', 'face_origin_y', 'wall_front_y',
            'wedge_left', 'wedge_right', 'wedge_rear_y', 'cavity_front',
            'cavity_rear', 'cavity_left', 'cavity_right']) {
            near(raised[key], zero[key]);
        }
        near(raised.wall_profile[0][1], 0);
        near(raised.wall_profile[1][1], 0);
    }
});

for (const angle of [15, 20, 30]) for (const height of [2, 4, 5]) {
    for (const offset of [0, 10, 50]) {
        test(`tab sockets ${angle}deg ${height}U offset ${offset}`, () => {
            const c = dimensions({ monitor_angle: angle,
                verticalUnits: height, monitor_offset_z: offset });
            assert.equal(c.tab_rows.length, 2);
            assert.ok(c.tab_rows[1] - c.tab_rows[0]
                > c.tab_length + 2 * c.tab_clearance + c.socket_wall);
            for (const side of [-1, 1]) for (const y of c.tab_rows) {
                const x = c.tab_x(side), bottom = c.tab_bottom(y);
                const lo = y - c.tab_length / 2;
                const hi = y + c.tab_length / 2;
                const z = c.side_screw_z(y);
                assert.ok(lo - c.tab_clearance - c.socket_wall
                    > c.cavity_front);
                assert.ok(hi + c.tab_clearance + c.socket_wall
                    < c.cavity_rear);
                assert.ok(bottom - c.tab_clearance > c.panel_depth);
                assert.ok(x > c.cavity_left);
                assert.ok(x + c.tab_thickness < c.cavity_right);
                // Blind pilots retain radial and closed-end tab material.
                assert.ok(z - c.screw_hole_diameter / 2 > bottom + 1);
                assert.ok(z + c.screw_hole_diameter / 2
                    < c.roof_z(lo) - 1);
                assert.ok(c.tab_thickness - c.side_pilot_depth >= 2);
                assert.ok(z - c.side_head_d / 2 > c.panel_depth);
                assert.ok(z + c.side_head_d / 2 < c.roof_z(y));
                // Side driver/head (6mm diameter) clears panel and roof.
                assert.ok(z - 3 > c.panel_depth);
                assert.ok(z + 3 < c.roof_z(y));
                // Grounded socket, vertical slot and retained floor; all
                // tab material below the rim fits the expanded slot.
                const slotX = [x - c.tab_clearance,
                    x + c.tab_thickness + c.tab_clearance];
                const slotY = [lo - c.tab_clearance,
                    hi + c.tab_clearance];
                for (const lift of [0, 0.2, 4, 8, 30]) {
                    for (const tx of [x, x + c.tab_thickness]) {
                        for (const ty of [lo, y, hi]) {
                            assert.ok(tx > slotX[0] && tx < slotX[1]);
                            assert.ok(ty > slotY[0] && ty < slotY[1]);
                            assert.ok(bottom + lift
                                > bottom - c.tab_clearance);
                            // Tab root overlaps solid roof, below monitor.
                            const q = local(c, ty, c.roof_z(ty) + 1);
                            assert.ok(q[1] > -c.face_thickness && q[1] < 0);
                        }
                    }
                }
                // A vertical driver can reach every rail screw with the
                // VESA plate removed; sockets never reach its XY corridor.
                const mountX = c.panel_width / 2 - c.RACK_RAIL_HEIGHT / 2;
                assert.ok(mountX - 3 > c.wedge_right);
                assert.ok(-mountX + 3 < c.wedge_left);
                // Default VESA head cylinders miss tabs/sockets in X.
                for (const v of [-1, 1]) {
                    const vx = c.vesa_x(v), sx = c.socket_x(side);
                    assert.ok(vx + c.driver_diameter / 2 < sx
                        || vx - c.driver_diameter / 2
                            > sx + c.socket_width + c.eps);
                }
            }
        });
    }
}

test('separate parts use outside clearance and blind receiving pilots', () => {
    const plate = source.split('module vesa_panel() {')[1]
        .split('module screw_paths()')[0];
    const base = source.split('module maker_panel() {')[1]
        .split('module assembly()')[0];
    assert.match(plate, /inclined_face\(\);\s*vesa_tabs\(\);/);
    assert.match(plate, /side_tab_pilots\(\);/);
    assert.match(base, /tab_slots\(\);\s*side_wall_screw_holes\(\);/);
    assert.doesNotMatch(plate, /side_wall_screw_holes\(\)/);
    assert.doesNotMatch(base, /side_tab_pilots\(\)/);
    assert.doesNotMatch(base, /inclined_face\(\)|vesa_tabs\(\)/);
    assert.match(source, /tab_bottom\(y\) - tab_clearance/);
    assert.doesNotMatch(source, /side_nut_|side_screw_diameter/);
    assert.match(source, /rotate\(\[0, -side \* 90, 0\]\) children\(\)/);
    assert.match(source, /side_screw_pose\(side, y, wall_thickness \+ tab_clearance\)/);
    assert.match(source, /h=side_pilot_depth \+ eps/);
    assert.match(source, /cylinder\(d1=side_head_d, d2=side_clearance_d,/);
    assert.match(source, /translate\(\[0, 0, assembly_lift\]\)/);
    assert.match(source, /if \(part == "vesa_panel"\)\s*\{\s*vesa_panel\(\);/);
});

test('cyberdeck hole dimensions retain clearance and blind pilot depth', () => {
    const c = dimensions();
    near(c.screw_hole_diameter, 2.5);
    near(c.screw_hole_taper_depth, 1.8);
    near(c.screw_hole_thread_depth, 7);
    near(c.screw_head_diameter, 5.25);
    near(c.side_clearance_d, 2.75);
    near(c.side_head_d, 5.45);
    near(c.side_taper_h, 2.2);
    near(c.side_pilot_depth, 8.8);
    near(c.tab_thickness - c.side_pilot_depth, 2.2);
    near(c.wall_thickness - c.side_taper_h, 1.8);
    for (const side of [-1, 1]) {
        const outside = side < 0 ? c.wedge_left : c.wedge_right;
        const entry = outside - side * (c.wall_thickness + c.tab_clearance);
        near(entry, c.tab_x(side) + (side > 0 ? c.tab_thickness : 0));
        const end = entry - side * c.side_pilot_depth;
        assert.ok(end > c.tab_x(side));
        assert.ok(end < c.tab_x(side) + c.tab_thickness);
    }
    const deeper = dimensions({ side_screw_head_recess_extra: 1 });
    near(deeper.side_taper_h, 2.8);
    near(deeper.side_pilot_depth, c.side_pilot_depth);
    const thin = dimensions({ wall_thickness: 1 });
    near(thin.side_taper_h, 1);
    const none = dimensions({ screw_hole_taper_depth: 0,
        side_screw_head_recess_extra: 0 });
    near(none.side_taper_h, 0);
    near(none.side_pilot_depth, 7);
});