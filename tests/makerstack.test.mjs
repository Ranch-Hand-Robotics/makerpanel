import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');
const config = read('../mkdocs.yml');
const home = read('../theme/home.html');
const css = read('../docs/css/site.css');
const openscad = read('../docs/openscad.md');
const feature = home.match(
  /<section class="makerstack-section\b[\s\S]*?<\/section>/)?.[0] ?? '';

test('MakerStack is a main navigation peer beside The standard', () => {
  assert.match(config,
    /  - The standard: specification\.md\r?\n  - MakerStack: makerstack\.md/);
  assert.equal((config.match(/- MakerStack:/g) ?? []).length, 1);
  assert.match(config, /use_directory_urls: false/);
});

test('homepage explains stacking and links to the canonical guide', () => {
  assert.ok(feature, 'Missing MakerStack homepage section');
  assert.match(feature, /aria-labelledby="makerstack-title"/);
  assert.match(feature, /id="makerstack-title"/);
  const text = feature.replace(/\s+/g, ' ');
  assert.match(text, /MakerRail hosts vertically/);
  assert.match(text, /ordinary flat MakerPanels/);
  assert.match(text, /Top-down fastener access/);
  assert.match(text, /Keep the driver paths clear/);
  assert.match(text, /removing the tiers above it first/);
  assert.match(feature,
    /href="{{ 'makerstack\.html' \| url }}">\s*Explore MakerStack/);
  const sections = [...home.matchAll(/class="eyebrow">(\d{2}) \//g)]
    .map(([, number]) => number);
  assert.deepEqual(sections, ['01', '02', '03', '04', '05']);
});

test('OpenSCAD docs link to the guide, not a retired proposal', () => {
  assert.match(openscad, /\[MakerStack guide\]\(makerstack\.md\)/);
  for (const source of [config, home, openscad]) {
    assert.doesNotMatch(source, /proposals\/makersta(?:ck|x)/i);
  }
  assert.doesNotMatch(feature,
    /discussion draft|potential specification|production.ready|load.rated/i);
});

test('schematic is labeled, accessible, static, and styled externally', () => {
  assert.match(feature, /role="img"\s+aria-label="Three flat panel tiers/);
  assert.match(feature, /aria-hidden="true"/);
  assert.match(feature, /<figcaption>[\s\S]*not a fabrication drawing/);
  assert.doesNotMatch(home, /<style\b|\sstyle\s*=/i);
  const rules = [...css.matchAll(/([^{}]+)\{([^{}]*)\}/g)]
    .filter(([, selector]) => selector.includes('.makerstack-'));
  assert.ok(rules.length > 0, 'Missing standalone MakerStack stylesheet rules');
  const declarations = rules.map(([, , body]) => body).join('\n');
  for (const token of ['ink', 'surface', 'surface-tint', 'accent', 'mono']) {
    assert.ok(declarations.includes(`var(--${token})`));
  }
  assert.doesNotMatch(declarations, /#[\da-f]{3,8}\b|\b(?:rgb|hsl)a?\(/i);
  assert.doesNotMatch(declarations, /\b(?:animation|transition)\s*:/);
  const template = read('../theme/main.html');
  assert.match(template, /rel="stylesheet"[^>]+css\/site\.css/);
  assert.match(template, /rel="stylesheet"[^>]+css\/theme\.css/);
});

test('navigation and feature retain responsive and focus safeguards', () => {
  assert.match(css, /\.site-nav\s*\{[^}]*flex-wrap: wrap;/);
  assert.match(css,
    /@media \(max-width: 820px\)\s*\{\s*\.makerstack-section/);
  assert.match(css,
    /\.makerstack-section \.section-split\s*\{[^}]*columns: 1fr;/);
  assert.match(css, /:focus-visible\s*\{[^}]*outline: 3px solid/);
  assert.match(css, /@media \(prefers-reduced-motion: reduce\)/);
});