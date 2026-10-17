// Source contracts and analytic layout checks, not mesh certification.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';

const read = path => readFileSync(new URL(`../${path}`, import.meta.url),
    'utf8');
const source = read('examples/grid_plate/GridPlate.scad');
const stack = read('makerpanel/makerstack.scad');
const common = read('makerpanel/common.scad');
const value = (text, name) => Number(text.match(
    new RegExp(`\\b${name}\\s*=\\s*([\\d.]+)\\s*;`))[1]);
const hp = value(common, 'HP');
const u = value(common, 'U');
const rail = value(common, 'RACK_RAIL_HEIGHT');
const mountD = value(common, 'MOUNT_HOLE_DIAMETER');
const web = value(source, 'mountWeb');
const pitch = value(source, 'gridPitch');
const hole = value(source, 'gridHoleDiameter');
const od = value(source, 'standoffDiameter');
const thickness = value(source, 'panelThickness');
const edge = Math.max(0, thickness - 1.2);
const specs = JSON.parse(stack.match(
    /function makerstack_sbc_specs\(\)\s*=\s*(\[[\s\S]*?\]);/)[1]);
const pointExpression = source.match(
    /function grid_plate_point_fits\([^;]*?=\s*([^;]+);/)[1];
const pointFunction = vm.compileFunction(`return ${pointExpression};`,
    ['p', 'size', 'radius', 'edge', 'abs']);
const pointFits = (p, size, radius, edge) =>
    pointFunction(p, size, radius, edge, Math.abs);
const centered = spec => spec[4].map(p =>
    [p[0] - spec[2] / 2, p[1] - spec[3] / 2]);
const distance = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const clear = (p, points, gap) => points.every(k => distance(p, k) >= gap);
const mounts = (w, h) => [-1, 1].flatMap(x =>
    (h < 1 ? [0] : [-1, 1]).map(y =>
        [x * (w * hp - rail) / 2, y * (h * u - rail) / 2]));
const fits = (spec, size, mounting) => spec[2] <= size[0]
    && spec[3] <= size[1] && centered(spec).every(p =>
    pointFits(p, size, od / 2, edge + 1)
        && clear(p, mounting, (od + mountD) / 2 + web));
const axis = (span, spacing) => {
    const n = spacing > 0 ? Math.floor(span / spacing) : -1;
    return n < 1 ? [] : Array.from({ length: n + 1 },
        (_, i) => (i - n / 2) * spacing);
};

test('grid example reuses bundled panel/grid/SBC APIs without deck imports', () => {
    assert.match(source, /use <makerpanel\/makerstack.scad>/);
    assert.match(source, /makerpanel_2d\(horizontalPitch, verticalUnits\)/);
    for (const helper of ['makerstack_grid_points', 'makerstack_grid_clear',
        'makerstack_sbc_selected', 'makerstack_sbc_mount_2d',
        'makerstack_sbc_standoffs']) {
        assert.ok(source.includes(`${helper}(`), helper);
        assert.doesNotMatch(source, new RegExp(`function ${helper}\\b`));
    }
    assert.doesNotMatch(source, /apache|riptide|hard_case|assert\(/i);
    assert.match(source, /sy = u < 1 \? \[0\] : \[-1, 1\]/);
    assert.match(source, /\(hp_to_mm\(hp\) - RACK_RAIL_HEIGHT\) \/ 2/);
    assert.match(source, /\(u_to_mm\(u\) - RACK_RAIL_HEIGHT\) \/ 2/);
});

test('default panel accepts all complete reference patterns', () => {
    const w = value(source, 'horizontalPitch');
    const h = value(source, 'verticalUnits');
    const size = [w * hp, h * u];
    assert.deepEqual(size, [177.8, 133.35000000000002]);
    assert.deepEqual(mounts(4, 0.5), [[-4.66, 0], [4.66, 0]]);
    for (const spec of specs) {
        assert.equal(centered(spec).length, 4);
        assert.ok(fits(spec, size, mounts(w, h)), spec[0]);
        assert.ok(!fits(spec, [4 * hp, 0.5 * u], mounts(4, 0.5)),
            'undersized panel must reject the entire pattern');
    }
    const points = specs.flatMap(centered);
    for (let i = 0; i < points.length; i++) {
        for (let j = i + 1; j < points.length; j++) {
            assert.ok(distance(points[i], points[j]) > od,
                'default combined pillars must not overlap');
        }
    }
});

test('point-fit predicate includes pillar radius and chamfer land', () => {
    assert.ok(pointFits([5, -5], [20, 20], 3, 2));
    assert.ok(!pointFits([5.01, -5], [20, 20], 3, 2));
    assert.ok(!pointFits([-5, -5.01], [20, 20], 3, 2));
    assert.match(source, /spec\[2\] <= size\[0\] && spec\[3\] <= size\[1\]/);
    assert.match(source, /diameter \/ 2, edge/);
    assert.match(source,
        /\(diameter \+ MOUNT_HOLE_DIAMETER\) \/ 2 \+ mountWeb/);
    assert.match(source, /if \(grid_plate_sbc_fits\([\s\S]*?\)\) spec/);
    assert.match(source, /pattern omitted: increase panel size/);
});

test('grid layouts preserve rail holes, standoff footprints, and edge land', () => {
    // Analytic mirror of the shared centered lattice; contracts below bind
    // its spacing and clearance formulas to the example and library.
    assert.match(stack, /\(i - n \/ 2\) \* pitch/);
    assert.match(stack, /pitch > 0 \? floor\(span \/ pitch\) : -1/);
    assert.match(source,
        /boardPoints, \(standoffDiameter \+ gridHoleDiameter\) \/ 2 \+ 1/);
    assert.match(source,
        /\(gridHoleDiameter \+ MOUNT_HOLE_DIAMETER\) \/ 2 \+ mountWeb/);
    assert.match(source,
        /max\(gridMargin, gridHoleDiameter \/ 2 \+ edgeInset \+ 1\)/);
    for (const [w, h] of [[4, 0.5], [20, 2], [35, 3], [48, 4]]) {
        const size = [w * hp, h * u];
        const mounting = mounts(w, h);
        for (const selected of [[], ...specs.map(s => [s]), specs]) {
            const posts = selected.filter(s => fits(s, size, mounting))
                .flatMap(centered);
            for (const spacing of [6.35, pitch, 25.4, 10, 20, 25]) {
                const margin = Math.max(value(source, 'gridMargin'),
                    hole / 2 + edge + 1);
                const grid = axis(size[0] - 2 * margin, spacing)
                    .flatMap(x => axis(size[1] - 2 * margin, spacing)
                        .map(y => [x, y]))
                    .filter(p => clear(p, posts, (od + hole) / 2 + 1)
                        && clear(p, mounting, (hole + mountD) / 2 + web));
                for (const p of grid) {
                    assert.ok(pointFits(p, size, hole / 2, edge + 1));
                    for (const m of mounting) {
                        assert.ok(distance(p, m) - (hole + mountD) / 2
                            >= web - 1e-9);
                    }
                    for (const post of posts) {
                        assert.ok(distance(p, post) - (hole + od) / 2
                            >= 1 - 1e-9);
                    }
                }
            }
        }
    }
    assert.deepEqual(axis(1, 12.7), []);
    assert.deepEqual(axis(10, 0), []);
    assert.deepEqual(axis(-10, 12.7), []);
});

test('printed bores stop at plate while flat output has screw holes', () => {
    assert.match(source, /grid_plate_2d\(sbc_holes = false\)/);
    assert.match(source, /translate\(\[0, 0, panelThickness\]\)/);
    assert.match(source, /module grid_plate_2d\(sbc_holes = true\)/);
    assert.match(source,
        /if \(sbc_holes\)[\s\S]*?translate\(p\) circle\(d = spec\[5\]\)/);
    assert.match(source,
        /else if \(part == "panel_2d"\)\s*\{\s*grid_plate_2d\(\);/);
    const relief = value(source, 'standoffRelief');
    const pilots = specs.map(s => Math.max(1, s[5] - relief));
    assert.deepEqual(pilots, [2.1, 2.1, 2.6]);
    assert.equal(thickness + value(source, 'standoffHeight'), 9);
});

test('gallery entry matches the example controls and files', () => {
    const gallery = JSON.parse(read('docs/gallery.json'));
    const entry = gallery.panels.find(p => p.slug === 'grid_plate');
    assert.equal(entry.horizontalPitch, value(source, 'horizontalPitch'));
    assert.equal(entry.verticalUnits, value(source, 'verticalUnits'));
    assert.deepEqual(entry.scadParts, ['makerpanel', 'panel_2d']);
    assert.equal(read(entry.scadFile), source);
    assert.match(read('examples/grid_plate/README.md'), /^---\r?\n/);
});