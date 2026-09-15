// Source contracts and analytic sections, not compiled mesh certification.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';

const root = new URL('../', import.meta.url);
const read = file => readFileSync(new URL(file, root), 'utf8');
const strip = text => text.replace(/\/\/[^\n]*|\/\*[\s\S]*?\*\//g, '');
const panel = strip(read('makerpanel/panel.scad'));
const near = (actual, expected) => assert.ok(
    Math.abs(actual - expected) < 1e-9, `${actual} != ${expected}`);

const direct = [
    'iris_keyboard/IrisMakerPanel.scad',
    'lilygo_screen_4_7_s3/lilygo_screen.scad',
    'lilygo_t-encoder-pro/design/lilygo_t-encoder-pro.scad',
    'monitor_panel/monitor.scad',
    'mouse_panel/MousePadPanel.scad',
    'prime79_panel/prime97_panel.scad',
    'streamdeck_panel/streamdeck_panel.scad',
];
const extruded = [
    ['Antenna/antenna.scad', 'antenna_maker_panel_2d'],
    ['joystick/design/joystick.scad', 'joystick_panel_2d'],
    ['power_panel/PowerPanel.scad', 'power_panel_2d'],
    ['rail_panel/RailPanel.scad', 'rail_panel_2d'],
    ['switch_panel/switch_panel.scad', 'switch_panel_2d'],
    ['trackball_panel/trackball_panel.scad', 'trackball_panel_2d'],
    ['vent_panel/VentPanel.scad', 'reinforced_vent_pattern_2d'],
];

for (const file of direct) {
    test(`${file}: printed panel opts into the 1.2 mm bevel`, () => {
        const source = strip(read(`examples/${file}`));
        assert.match(source,
            /makerpanel\([\s\S]*?chamfer_start\s*=\s*1\.2\s*\)/);
    });
}

for (const [file, profile] of extruded) {
    test(`${file}: finished cutout profile uses outside-only extrusion`, () => {
        const source = strip(read(`examples/${file}`));
        assert.match(source, new RegExp(
            'panel_extrude\\([\\s\\S]*?chamfer_start\\s*=\\s*1\\.2'
            + `\\s*\\)\\s*\\{?\\s*${profile}\\(`));
    });
}

test('shared makerpanel remains square by default; holes are never scaled', () => {
    assert.match(panel, /module makerpanel\([^{}]*chamfer_start=undef\)/);
    assert.match(panel, /module panel_extrude\(size, thickness, chamfer_start=1\.2\)/);
    assert.match(panel, /if \(bevel == 0\)\s*linear_extrude\(height=thickness\) children\(0\)/);
    assert.match(panel, /intersection\(\)\s*\{\s*linear_extrude\(height=thickness\) children\(0\)/);
    assert.match(panel, /scale=\[[\s\S]*?\]\s*\)\s*square\(size, center=true\)/);
    assert.doesNotMatch(panel, /scale=\[[\s\S]*?\]\s*\)\s*children/);
});

test('source-derived sections start at 1.2 mm and taper one-to-one', () => {
    const startExpression = panel.match(/\bstart = ([^;]+);/)[1];
    const bevelExpression = panel.match(/\bbevel = ([^;]+);/)[1];
    const scales = panel.match(/scale=\[([\s\S]*?)\]/)[1]
        .split(/,\s*(?=max)/);
    for (const thickness of [0.8, 1, 1.2, 1.6, 2, 3, 4, 6]) {
        for (const chamfer_start of [undefined, 1.2]) {
            const c = vm.createContext({ thickness, chamfer_start,
                is_undef: x => x === undefined, max: Math.max,
                size: { x: 91.44, y: 177.8 } });
            c.start = vm.runInContext(startExpression, c);
            c.bevel = vm.runInContext(bevelExpression, c);
            near(c.bevel, chamfer_start === undefined
                ? 0 : Math.max(0, thickness - 1.2));
            if (c.bevel === 0) continue;
            const top = scales.map(expr => vm.runInContext(expr, c));
            for (const [axis, index] of [['x', 0], ['y', 1]]) {
                const width = c.size[axis];
                near(width * (1 - top[index]) / 2, thickness - 1.2);
                for (const fraction of [0, 0.25, 0.5, 1]) {
                    const z = c.start + c.bevel * fraction;
                    const section = width * (1 + (top[index] - 1) * fraction);
                    near((width - section) / 2, z - 1.2);
                }
            }
        }
    }
});

test('0U rack uses the real outline, not slots or a bounding rectangle', () => {
    const rack = strip(read('makerpanel/rack.scad'));
    const rail = strip(read('examples/rail_panel/RailPanel.scad'));
    assert.match(rail, /rail_panel_2d\(\);\s*rack_single_rail_outline_2d\(/);
    assert.match(rack, /module rack_single_rail_2d\([\s\S]*?difference\(\)\s*\{\s*rack_single_rail_outline_2d\(/);
    assert.match(panel, /else if \(\$children > 1\)\s*difference\(\)/);
    assert.match(panel, /offset\(delta=bevel\) children\(1\);\s*children\(1\)/);
    // The exterior cutter's pyramid expands exactly one mm per mm of rise.
    const points = vm.runInNewContext(
        panel.match(/points=(\[[\s\S]*?\]),\s*faces=/)[1], { bevel: 1.8 });
    near(points[0][2], 0);
    for (const [x, y, z] of points.slice(1)) {
        near(Math.abs(x), z);
        near(Math.abs(y), z);
    }
});

test('measurement gauge and keyboard reference helpers stay square', () => {
    for (const file of ['measure/measure.scad', 'keyboard/cmx.scad',
        'keyboard/kinst_mf34.scad']) {
        assert.doesNotMatch(strip(read(`examples/${file}`)),
            /chamfer_start|panel_extrude/);
    }
});