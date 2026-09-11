import test from 'node:test';
import assert from 'node:assert/strict';
import path from 'node:path';
import { containedPath, sourceFor, overrideArgs } from '../scripts/thumbnails/lib.mjs';
import { thumbnailVariants } from '../docs/js/gallery-thumbnails.mjs';

test('explicit and uploaded images take priority over CAD', () => {
  const panel = { thumbnail: 'panels/test/images/thumb.png', scadFile: 'model.scad' };
  assert.deepEqual(sourceFor(panel), { type: 'image', path: 'docs/panels/test/images/thumb.png' });
  assert.deepEqual(sourceFor(panel, { image: 'photo.jpg' }), { type: 'image', path: 'photo.jpg' });
  assert.equal(sourceFor({ thumbnail: 'https://example.com/photo.png' }).type, 'remote');
});
test('brand placeholders and old generated thumbnails fall back to CAD', () => {
  for (const thumbnail of ['', 'images/makerpanel.png', 'images/panels/generated/test.png']) {
    assert.deepEqual(sourceFor({ thumbnail, scadFile: 'a.scad' }, { scadFile: 'b.scad' }),
      { type: 'scad', path: 'b.scad' });
  }
});
test('local paths cannot escape the checkout', () => {
  const root = path.resolve('test-root');
  assert.equal(containedPath(root, 'examples/model.scad'), path.join(root, 'examples/model.scad'));
  for (const invalid of ['../outside', '', undefined, root]) {
    assert.throws(() => containedPath(root, invalid));
  }
});
test('SCAD overrides quote strings and reject invalid arguments', () => {
  assert.deepEqual(overrideArgs({ part: 'panel', $fn: 32, visible: true }),
    ['-D', 'part="panel"', '-D', '$fn=32', '-D', 'visible=true']);
  assert.throws(() => overrideArgs({ 'a;b': 1 }));
  assert.throws(() => overrideArgs({ a: Infinity }));
});
test('gallery prefers paired variants but tolerates absent generated output', () => {
  const panel = { slug: 'test', thumbnail: 'photo.png' };
  assert.deepEqual(thumbnailVariants(panel, { panels: { test: { light: 'l.png', dark: 'd.png' } } }),
    { light: 'l.png', dark: 'd.png' });
  assert.deepEqual(thumbnailVariants(panel, {}), { light: 'photo.png', dark: 'photo.png' });
  assert.equal(thumbnailVariants({ thumbnail: 'images/makerpanel.png' }, {}), null);
  assert.deepEqual(thumbnailVariants(panel, { panels: { test: { light: 'l.png' } } }),
    { light: 'photo.png', dark: 'photo.png' });
});