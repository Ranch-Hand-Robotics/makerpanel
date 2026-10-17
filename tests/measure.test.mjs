import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';

// Source contracts; rendering is checked separately in the OpenSCAD preview.
const source = readFileSync(
    new URL('../examples/measure/measure.scad', import.meta.url), 'utf8');

for (const name of ['rail_ruler', 'panel_ruler']) {
    test(`${name} has a white base and black raised markings`, () => {
        const body = source.split(`module ${name}() {`)[1]?.split('\nmodule ')[0];
        assert.ok(body);
        assert.match(body, /color\("white"\)\s*cube\(/);
        assert.match(body, /color\("black"\)\s*for\s*\(/);
    });
}