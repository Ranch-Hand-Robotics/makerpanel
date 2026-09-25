import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = file => readFileSync(new URL(file, import.meta.url), 'utf8');
const stack = read('../makerpanel/makerstack.scad');
const rails = read('../makerpanel/rails.scad');
const common = read('../makerpanel/common.scad');
const constant = name => Number(common.match(
  new RegExp(`^${name} = ([\\d.]+);`, 'm'))[1]);
const rail = constant('RACK_RAIL_HEIGHT');
const bridge = constant('RACK_SUPPORT_WIDTH');
const unit = constant('U');
const canonical = stack.split('module makerstack_canonical_rails_2d(')[1]
  .split('module makerstack_top_2d(')[0];
const channels = stack.split('module makerstack_nut_channels(')[1]
  .split('module makerstack_bottom_openings(')[0];

// Evaluate only the arithmetic lengths actually passed by the source.
const expression = text => {
  assert.match(text, /^[\w\s+*\-/]+$/);
  return new Function('spacing', 'rail', 'RACK_SUPPORT_WIDTH',
    `return ${text};`);
};
const yLength = expression(canonical.match(/length = ([^;]+);/)[1]);
const yPocket = expression(channels.match(
  /rotate\(\[0, 0, 90\]\)\s*makerstack_nut_channel\(([^,]+),/)[1]);

test('Y rails butt into X rails without oversized added end pads', () => {
  assert.doesNotMatch(canonical, /square\(/);
  assert.match(canonical,
    /translate\(\[-length \/ 2, 0\]\)\s*maker_rail_2d\(length, rail,/);
  assert.match(rails, /edge_support_width=RACK_SUPPORT_WIDTH/);
  assert.match(rails, /: width - 2 \* edge_support_width/);
  assert.match(rails,
    /first_slot_pos = mounting_holes \? height : edge_support_width/);
  for (const u of [2, 3, 4, 6]) {
    const spacing = u * unit - rail;
    const length = yLength(spacing, rail, bridge);
    assert.equal(length, spacing - rail);
    const end = length / 2 - bridge;
    assert.ok(Math.abs(spacing / 2 - rail / 2 - end - bridge) < 1e-9);
    assert.equal(bridge, 3);
  }
});

test('Y nut pockets reach both terminal slot ends, not old 11mm pads', () => {
  for (const u of [2, 3, 4, 6]) {
    const spacing = u * unit - rail;
    const length = yLength(spacing, rail, bridge);
    const pocket = yPocket(spacing, rail, bridge);
    assert.equal(pocket, length - 2 * bridge);
    const oldPocket = spacing - 3 * rail;
    assert.ok(Math.abs((pocket - oldPocket) / 2 - 8) < 1e-9);
    // New pocket must not enter the 8.5mm corner nut-guide gap/walls.
    assert.ok(spacing / 2 - pocket / 2 > (8 + 2 * 0.25) / 2);
  }
});

test('X rails, centered support outlines and joint axes stay canonical', () => {
  assert.match(canonical,
    /maker_rail_2d\(frame \+ rail, rail, mounting_holes = false\)/);
  assert.match(channels, /makerstack_nut_channel\(frame \+ width,/);
  assert.match(stack,
    /square\(\[frame \+ width, spacing \+ width\], center = true\)/);
  assert.match(stack,
    /square\(\[frame - width, spacing - width\], center = true\)/);
  assert.match(stack, /function makerstack_post_x\([^)]*\) = frame \/ 2;/);
  assert.match(stack,
    /square\(\[joint_width, T_SLOT_HEIGHT\], center = true\)/);
});