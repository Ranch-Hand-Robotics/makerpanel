// Source contracts only: no OpenSCAD executable or generated SCAD required.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');

// [path, default, other Customizer options, base module, assembly module]
// A null assembly module means the assembly dispatch calls the base directly.
const samples = [
    ['Antenna/antenna.scad', 'assembly', ['assembly', 'panel_2d'],
        'antenna_maker_panel', null],
    ['iris_keyboard/IrisMakerPanel.scad', 'assembly',
        ['assembly', 'iris_keyboard_laser'],
        'iris_keyboard', 'iris_keyboard_assembly'],
    ['joystick/design/joystick.scad', 'assembly', ['assembly', 'panel_2d'],
        'joystick_panel', null],
    ['lilygo_screen_4_7_s3/lilygo_screen.scad', 'assembly',
        ['assembly', 'lilygo_screen', 'lilygo_pcb'], 'lilygo_makerpanel', null],
    ['lilygo_t-encoder-pro/design/lilygo_t-encoder-pro.scad',
        'makerpanel', [], 'lilygo_panel', null],
    ['measure/measure.scad', 'makerpanel', ['rail', 'rack'],
        'panel_ruler', null],
    ['monitor_panel/monitor.scad', 'assembly',
        ['assembly', 'vesa_panel'],
        'maker_panel', 'assembly'],
    ['mouse_panel/MousePadPanel.scad', 'makerpanel',
        ['mousepad_panel_laser', 'assembly'],
        'mousepad_panel', 'mousepad_assembly'],
    ['power_panel/PowerPanel.scad', 'makerpanel', ['panel_2d'],
        'power_panel', null],
    ['prime79_panel/prime97_panel.scad', 'assembly',
        ['assembly', 'prime79_keyboard_laser'],
        'prime79_keyboard', 'prime79_keyboard_assembly'],
    ['rail_panel/RailPanel.scad', 'makerpanel', ['rail_panel_2d'],
        'rail_panel', null],
    ['streamdeck_panel/streamdeck_panel.scad', 'assembly',
        ['assembly', 'bottom'], 'streamdeck_panel', 'streamdeck_assembly'],
    ['switch_panel/switch_panel.scad', 'assembly', ['assembly', 'panel_2d'],
        'switch_panel', null],
    ['trackball_panel/trackball_panel.scad', 'makerpanel',
        ['panel_2d', 'assembly', 'footprint'],
        'trackball_panel', 'trackball_assembly'],
    ['vent_panel/VentPanel.scad', 'makerpanel', ['panel_2d'],
        'vent_panel', null],
];

function read(file) {
    return fs.readFileSync(path.join(__dirname, file), 'utf8');
}

function uncomment(source) {
    return source.replace(/"(?:\\.|[^"\\])*"|\/\/[^\n]*|\/\*[\s\S]*?\*\//g,
        token => token.startsWith('/') ? ' ' : token);
}

function block(source, marker) {
    const match = marker.exec(source);
    assert.ok(match, `Missing block: ${marker}`);
    const start = source.indexOf('{', match.index);
    let depth = 1;
    for (let i = start + 1; i < source.length; i++) {
        if (source[i] === '{') depth++;
        if (source[i] === '}' && --depth === 0) {
            return source.slice(start + 1, i).trim();
        }
    }
    assert.fail(`Unclosed block: ${marker}`);
}

function branch(source, selector) {
    return block(source,
        new RegExp(`if\\s*\\(part == "${selector}"\\)\\s*\\{`));
}

function scadFiles(dir = __dirname, prefix = '') {
    // Never traverse vendored code, firmware dependencies, or Git internals.
    const ignored = new Set(['IsoGridScad', 'software', '.git', 'node_modules']);
    return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
        if (ignored.has(entry.name)) return [];
        const relative = prefix + entry.name;
        if (entry.isDirectory()) {
            return scadFiles(path.join(dir, entry.name), relative + '/');
        }
        return entry.isFile() && entry.name.endsWith('.scad') ? [relative] : [];
    });
}

test('every non-vendored SCAD entry point is classified', () => {
    const helpers = ['keyboard/cmx.scad', 'keyboard/kinst_mf34.scad'];
    assert.deepEqual(scadFiles().sort(),
        [...samples.map(([file]) => file), ...helpers].sort());
});

for (const [file, initial, others, base, assembly] of samples) {
    test(`${file}: canonical base and retained outputs`, () => {
        const raw = read(file);
        const source = uncomment(raw);
        const declarations = [...raw.matchAll(
            /^part\s*=\s*"([^"]+)";\s*\/\/\s*\[([^\]]+)\]/gm)];
        assert.equal(declarations.length, 1);
        const [, actualDefault, optionText] = declarations[0];
        assert.equal(actualDefault, initial);
        assert.deepEqual(optionText.split(',').map(s => s.trim()).sort(),
            ['makerpanel', ...others].sort());
        assert.doesNotMatch(source, /\bparts\s*(?:=|==)/);
        assert.doesNotMatch(source, /\b(?:module|function)\s+makerpanel\s*\(/);
        assert.equal(branch(source, 'makerpanel'), `${base}();`);
        for (const selector of others) {
            // Pre-existing unimplemented rack gauge uses the final fallback.
            if (file === 'measure/measure.scad' && selector === 'rack') {
                assert.match(source, /else\s*\{\s*rack_ruler\(\);\s*\}/);
            } else {
                assert.ok(branch(source, selector).length > 0);
            }
        }

        if (others.includes('assembly')) {
            const dispatch = branch(source, 'assembly');
            assert.equal(dispatch, `${assembly || base}();`);
            if (assembly) {
                const body = block(source,
                    new RegExp(`module ${assembly}\\([^)]*\\)\\s*\\{`));
                // Color and children do not change placement. The primary
                // base must precede any companion transforms or geometry.
                const prefix = assembly === 'iris_keyboard_assembly'
                    ? 'panel_width_mm = hp_to_mm(horizontalPitch);' : '';
                const normalized = body.replace(/\s+/g, ' ');
                const baseStart = normalized.slice(prefix.length).trim();
                assert.match(baseStart, new RegExp(
                    `^(?:color\\("[^"\\n]+"\\) )?${base}\\(\\)`));
            }
        }
    });
}

test('Iris companion remains mirrored and adjacent to the primary origin', () => {
    const source = uncomment(read('iris_keyboard/IrisMakerPanel.scad'));
    const body = block(source, /module iris_keyboard_assembly\(\)\s*\{/);
    assert.equal(body.replace(/\s+/g, ' '),
        'panel_width_mm = hp_to_mm(horizontalPitch); iris_keyboard(); '
        + 'translate([panel_width_mm, 0, 0]) mirror([1, 0, 0]) iris_keyboard();');
});

test('trackball base has no assembly-only offset or rotation', () => {
    const source = uncomment(read('trackball_panel/trackball_panel.scad'));
    const body = block(source, /module trackball_assembly\(\)\s*\{/);
    assert.equal(body.replace(/\s+/g, ' '),
        'trackball_panel(); '
        + '%translate([0, trackballOffsetY, -footprint_preview_thickness]) '
        + 'linear_extrude(height = footprint_preview_thickness) '
        + 'trackball_footprint_2d();');
});

test('trackball opening and module bolts move together within a fixed panel',
    () => {
        const source = uncomment(read('trackball_panel/trackball_panel.scad'));
        const scalar = name => Number(source.match(
            new RegExp(`\\b${name}\\s*=\\s*(-?[\\d.]+);`))[1]);
        assert.equal(scalar('openingWidth'), 54);
        assert.equal(scalar('openingInset'), 3);
        assert.equal(scalar('trackballOffsetY'), 20);
        assert.match(source, new RegExp(
            'opening_size\\s*=\\s*\\[openingWidth,\\s*'
            + 'trackball_hole_pitch\\.y\\s*-\\s*2\\s*\\*\\s*openingInset\\]'));
        const pitch = source.match(
            /trackball_hole_pitch\s*=\s*\[([\d.]+),\s*([\d.]+)\]/);
        const rowPitch = Number(pitch[2]);
        const height = rowPitch - 2 * scalar('openingInset');
        const offset = scalar('trackballOffsetY');
        const close = (actual, expected) =>
            assert.ok(Math.abs(actual - expected) < 1e-9);
        close(height, 80.8);
        close(offset - height / 2, -20.4);
        close(offset + height / 2, 60.4);
        for (const sign of [-1, 1]) {
            const rowY = offset + sign * rowPitch / 2;
            const edgeY = offset + sign * height / 2;
            close(Math.abs(rowY - edgeY), 3);
            close(Math.abs(rowY - edgeY)
                - scalar('trackball_hole_diameter') / 2, 1.9);
        }
        assert.match(source,
            /trackball_offset\s*=\s*\[0,\s*trackballOffsetY\]/);
        const panel = block(source, /module trackball_panel_2d\(\)\s*\{/);
        assert.equal(panel.replace(/\s+/g, ' '),
            'validate_trackball_panel() difference() { '
            + 'makerpanel_2d(horizontalPitch, verticalUnits); '
            + 'translate(trackball_offset) { trackball_mount_holes_2d(); '
            + 'square(opening_size, center = true); } }');
        assert.equal(branch(source, 'footprint'), 'trackball_footprint_2d();');
    });

test('monitor exposes separate fixed base and VESA plate plus preview', () => {
    const source = uncomment(read('monitor_panel/monitor.scad'));
    assert.deepEqual([...source.matchAll(/part == "([^"]+)"/g)]
        .map(match => match[1]), ['assembly', 'makerpanel', 'vesa_panel']);
    assert.doesNotMatch(source,
        /\b(?:deployment|slider|brace|clevis|magnet|stow)\w*\b/);
});