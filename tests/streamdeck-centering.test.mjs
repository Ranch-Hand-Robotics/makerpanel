// Source-derived analytic checks; rendered geometry is validated separately.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';

const read = path => readFileSync(new URL(path, import.meta.url), 'utf8')
    .replace(/\/\/[^\n]*|\/\*[\s\S]*?\*\//g, '');
const source = read('../examples/streamdeck_panel/streamdeck_panel.scad');
const common = read('../makerpanel/common.scad');
const near = (a, b) => assert.ok(Math.abs(a - b) < 1e-9, `${a} != ${b}`);

function dimensions(kind, tilt, units = 2.5) {
    const context = vm.createContext({
        sin: x => Math.sin(x * Math.PI / 180),
        cos: x => Math.cos(x * Math.PI / 180),
        tan: x => Math.tan(x * Math.PI / 180),
        abs: Math.abs, ceil: Math.ceil, max: Math.max,
    });
    // These dimension functions use the same expression syntax as JavaScript.
    for (const text of [common, source]) {
        // Top-level defaults are unindented; skip module-local assignments.
        for (const [, name, expression] of text.matchAll(
            /^(\w+)\s*=\s*([^;]+);/gm)) {
            context[name] = vm.runInContext(expression, context);
        }
        for (const [, name, args, expression] of text.matchAll(
            /function\s+(\w+)\(([^)]*)\)\s*=\s*([^;]+);/g)) {
            vm.runInContext(
                `function ${name}(${args}) { return ${expression}; }`,
                context);
        }
    }
    context.module_type = kind;
    context.tilt_angle = tilt;
    context.verticalUnits = units;
    return context;
}

test('tilted sleeve footprint is centered between the rail strips', () => {
    for (const kind of ['6_key', '15_key', '32_key']) {
        for (const tilt of [0, 5, 15, 25]) {
            for (const units of [2, 2.5, 3, 4, 8]) {
                const d = dimensions(kind, tilt, units);
                // Independently intersect the rotated sleeve sides with Z=0.
                const center = d.streamdeck_seat_y()
                    + d.streamdeck_seat_z() * d.tan(tilt);
                const halfDepth = d.streamdeck_outer_height()
                    / (2 * d.cos(tilt));
                const wellHalf = d.u_to_mm(d.effective_vertical_units()) / 2
                    - d.RACK_RAIL_HEIGHT;
                near(center, 0);
                near(d.streamdeck_foot_y(), center);
                near(wellHalf - (center + halfDepth),
                    center - halfDepth + wellHalf);
                assert.ok(wellHalf >= halfDepth);
            }
        }
    }
});

test('15-key module keeps equal margins at 2.5U and 15 degrees', () => {
    const d = dimensions('15_key', 15);
    near(d.effective_vertical_units(), 2.5);
    assert.ok(d.streamdeck_seat_y() < -2.7);
    assert.ok(d.streamdeck_seat_y() > -2.72);
    const margin = d.u_to_mm(2.5) / 2 - d.RACK_RAIL_HEIGHT
        - d.streamdeck_foot_depth() / 2;
    assert.ok(margin > 4 && margin < 4.1);
});

test('device, retainer flanges, and bolt pattern share corrected placement',
    () => {
        assert.match(source, new RegExp(
            'module streamdeck_placement\\(\\)\\s*\\{\\s*'
            + 'translate\\(\\[0, streamdeck_seat_y\\(\\), '
            + 'streamdeck_seat_z\\(\\)\\]\\)'));
        assert.match(source,
            /streamdeck_foot_y\(\) \+ end\*streamdeck_bolt_y_offset\(\)/);
        assert.match(source,
            /side\*streamdeck_bolt_x\(\), streamdeck_foot_y\(\)/);
        assert.match(source,
            /translate\(\[0, streamdeck_foot_y\(\), -rear_flange_depth\/2\]\)/);
    });

test('rear-only trim increases rail clearance without moving bolts', () => {
    const d = dimensions('15_key', 15);
    near(d.rear_rail_trim, 2);
    near(d.streamdeck_rear_depth(), d.streamdeck_foot_depth() - 4);
    const margin = d.u_to_mm(2.5) / 2 - d.RACK_RAIL_HEIGHT
        - d.streamdeck_rear_depth() / 2;
    assert.ok(margin > 6 && margin < 6.1);
    const boltEdge = d.streamdeck_rear_depth() / 2
        - d.streamdeck_bolt_y_offset() - d.rear_bolt_diameter / 2;
    near(boltEdge, 8.4);
    // Clipping is part of the exported retainer, not the host panel.
    assert.match(source,
        /module streamdeck_rear\(\)\s*\{\s*difference\(\)/);
    assert.match(source, /intersection\(\)\s*\{\s*streamdeck_rear_solid\(\);/);
    assert.match(source,
        /cube\(\[2\*streamdeck_cut_span\(\), streamdeck_rear_depth\(\),/);
});

test('trim retains bearing overlap through the rear plate thickness', () => {
    for (const kind of ['6_key', '15_key', '32_key']) {
        for (let tilt = 0; tilt <= 25; tilt++) {
            const d = dimensions(kind, tilt);
            const half = d.streamdeck_rear_depth() / 2;
            const openingHalf = d.module_height() / 2 - d.rear_support_width;
            for (const z of [d.streamdeck_rear_seat_z(),
                d.streamdeck_rear_seat_z() - d.rear_plate_depth]) {
                // Express world-Y clipping planes in local device coordinates.
                const localMin = (-half - d.streamdeck_seat_y()
                    + z * d.sin(tilt)) / d.cos(tilt);
                const localMax = (half - d.streamdeck_seat_y()
                    + z * d.sin(tilt)) / d.cos(tilt);
                const overlap = Math.min(d.module_height() / 2,
                    -localMin, localMax) - openingHalf;
                assert.ok(overlap >= 4,
                    `${kind} at ${tilt} degrees: ${overlap} mm bearing`);
            }
        }
    }
});