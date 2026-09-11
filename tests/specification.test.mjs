import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const specification = readFileSync(
  new URL('../docs/specification.md', import.meta.url), 'utf8');

test('standard diagrams have unique accessible titles and descriptions', () => {
  const figures = [...specification.matchAll(
    /<figure class="spec-diagram">([\s\S]*?)<\/figure>/g)];
  assert.equal(figures.length, 8);
  const ids = new Set();
  for (const [, figure] of figures) {
    assert.match(figure, /viewBox="0 0 \d+ \d+"/);
    assert.match(figure, /role="img"/);
    const labels = figure.match(/aria-labelledby="([^"]+)"/);
    assert.ok(labels);
    const [title, description] = labels[1].split(' ');
    for (const [tag, id] of [['title', title], ['desc', description]]) {
      assert.ok(id);
      assert.ok(!ids.has(id), `Duplicate SVG ID: ${id}`);
      ids.add(id);
      assert.ok(figure.includes(`<${tag} id="${id}">`));
    }
    assert.match(figure, /<figcaption>.+<\/figcaption>/);
    assert.doesNotMatch(figure, /<style|style=/);
  }
  assert.doesNotMatch(specification, /```|[┌┐└┘├┤]/);
});

test('assembly holes align with rail centers at half-width edge insets', () => {
  const element = (id) => {
    const match = specification.match(new RegExp(`<[^>]+id="${id}"[^>]*>`));
    assert.ok(match, `Missing assembly element: ${id}`);
    return Object.fromEntries([...match[0].matchAll(/(\w+)="([\d.]+)"/g)]
      .map(([, key, value]) => [key, Number(value)]));
  };
  const panel = element('assembly-panel');
  const top = element('assembly-top-rail');
  const bottom = element('assembly-bottom-rail');
  const inset = top.height / 2;
  assert.equal(top.height, 22); // 11 mm at 2 SVG units per mm.
  assert.equal(bottom.height, top.height);
  assert.equal(panel.height / 2, 128.5);
  assert.equal(top.y, panel.y);
  assert.equal(bottom.y + bottom.height, panel.y + panel.height);
  const holes = specification.match(
    /<g id="assembly-holes"[^>]*>([\s\S]*?)<\/g>/)[1];
  const points = [...holes.matchAll(/<circle cx="([\d.]+)" cy="([\d.]+)"/g)]
    .map(([, x, y]) => [Number(x), Number(y)]);
  const xs = [panel.x + inset, panel.x + panel.width - inset];
  const ys = [top.y + inset, bottom.y + inset];
  assert.deepEqual(points, ys.flatMap(y => xs.map(x => [x, y])));
  assert.equal(ys[0] - panel.y, inset);
  assert.equal(panel.y + panel.height - ys[1], inset);
  assert.equal((ys[1] - ys[0]) / 2, 117.5);
  for (const [name, coordinate] of [['top', ys[0]], ['bottom', ys[1]]]) {
    const line = element(`assembly-${name}-center`);
    assert.equal(line.y1, coordinate);
    assert.equal(line.y2, coordinate);
  }
  for (const [name, coordinate] of [['left', xs[0]], ['right', xs[1]]]) {
    const line = element(`assembly-${name}-center`);
    assert.equal(line.x1, coordinate);
    assert.equal(line.x2, coordinate);
  }
});

test('diagram stylesheet is scoped and uses the existing theme tokens', () => {
  const css = readFileSync(
    new URL('../docs/css/specification.css', import.meta.url), 'utf8');
  const template = readFileSync(
    new URL('../theme/main.html', import.meta.url), 'utf8');
  for (const token of ['ink', 'surface', 'accent', 'accent-dark']) {
    assert.ok(css.includes(`var(--${token})`));
  }
  assert.match(css, /\.spec-diagram svg\s*\{[^}]*height: auto;/);
  assert.match(template,
    /if page.file.src_uri == 'specification.md'[\s\S]*?css\/specification.css/);
});