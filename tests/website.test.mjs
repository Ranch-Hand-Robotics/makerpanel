import test from 'node:test';
import assert from 'node:assert/strict';
import { selectPanels, safeUrl, panelSize } from '../docs/js/gallery-data.mjs';

const panels = [
  { title: 'Screen', category: 'Visual Feedback', horizontalPitch: 26, verticalUnits: 2 },
  { title: 'Encoder', description: 'Rotary control', category: 'Analog Control', horizontalPitch: 9, verticalUnits: 1 },
  { title: 'Blank', category: 'Other', horizontalPitch: null, verticalUnits: null },
  { title: 'Unknown width', category: 'Other' },
];

test('search is case insensitive and matches all words across metadata', () => {
  assert.deepEqual(selectPanels(panels, { query: ' ROTARY encoder ' }).map(p => p.title), ['Encoder']);
  assert.equal(selectPanels(panels, { query: 'unavailable' }).length, 0);
});
test('category combines with search rather than replacing it', () => {
  assert.equal(selectPanels(panels, { category: 'Other' }).length, 2);
  assert.equal(selectPanels(panels, { query: 'screen', category: 'Other' }).length, 0);
});
test('width sort puts unknown dimensions last and leaves catalog unchanged', () => {
  assert.deepEqual(selectPanels(panels, { sort: 'width' }).map(p => p.title),
    ['Encoder', 'Screen', 'Blank', 'Unknown width']);
  assert.equal(panels[0].title, 'Screen');
});
test('dimension labels never invent unknown sizes', () => {
  assert.equal(panelSize(panels[1]), '9 HP / 1U');
  assert.equal(panelSize(panels[2]), 'Dimensions in source');
  assert.equal(panelSize({ horizontalPitch: 35, verticalUnits: 0.375 }), '35 HP / 0.375U');
});
test('links resolve under GitHub Pages subpaths and reject unsafe protocols', () => {
  const base = 'https://example.com/makerpanel/gallery.html';
  assert.equal(safeUrl('panels/encoder/index.html', 'index.html', base),
    'https://example.com/makerpanel/panels/encoder/index.html');
  for (const input of ['javascript:alert(1)', 'data:text/html,test', 'file:///test', 'http://[invalid']) {
    assert.equal(safeUrl(input, 'index.html', base), 'https://example.com/makerpanel/index.html');
  }
});
test('empty and incomplete catalogs remain usable', () => {
  assert.deepEqual(selectPanels([]), []);
  assert.deepEqual(selectPanels([{}], { category: 'Other' }), [{}]);
  assert.equal(panelSize({}), 'Dimensions in source');
});