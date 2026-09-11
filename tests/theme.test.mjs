import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../docs/js/theme.js', import.meta.url), 'utf8');

function setup({ saved = null, dark = false, blocked = false } = {}) {
  const handlers = {};
  const storage = new Map(saved === null ? [] : [['makerpanel-theme', saved]]);
  const root = { dataset: {} };
  const meta = {};
  const button = {
    hidden: true,
    attributes: {},
    setAttribute(name, value) { this.attributes[name] = value; },
    addEventListener: (name, fn) => { handlers[name] = fn; },
  };
  const media = {
    matches: dark,
    addEventListener: (_, fn) => { handlers.system = fn; },
  };
  let ready = false;
  const access = fn => {
    if (blocked) throw new Error('Storage blocked');
    return fn();
  };
  runInNewContext(source, {
    matchMedia: () => media,
    localStorage: {
      getItem: key => access(() => storage.get(key) ?? null),
      setItem: (key, value) => access(() => storage.set(key, value)),
      removeItem: key => access(() => storage.delete(key)),
    },
    document: {
      documentElement: root,
      querySelector: () => meta,
      querySelectorAll: () => ready ? [button] : [],
      addEventListener: (_, fn) => { handlers.ready = fn; },
    },
    window: {
      addEventListener: (_, fn) => { handlers.storage = fn; },
    },
  });
  return {
    root, meta, storage, button,
    mount() { ready = true; handlers.ready(); },
    click() { handlers.click(); },
    system(value) { media.matches = value; handlers.system(); },
    sync(key, newValue) { handlers.storage({ key, newValue }); },
  };
}

test('first visit follows the system before controls mount', () => {
  for (const dark of [true, false]) {
    const app = setup({ dark });
    assert.equal(app.root.dataset.theme, dark ? 'dark' : 'light');
    assert.equal(app.meta.content, dark ? '#171c18' : '#f3f1e9');
    assert.equal(app.button.hidden, true);
    app.mount();
    assert.equal(app.button.attributes['aria-pressed'], String(dark));
    assert.equal(app.button.hidden, false);
    app.system(!dark);
    assert.equal(app.root.dataset.theme, dark ? 'light' : 'dark');
  }
});

test('saved overrides apply immediately and ignore system changes', () => {
  for (const saved of ['light', 'dark']) {
    const app = setup({ saved, dark: saved === 'light' });
    assert.equal(app.root.dataset.theme, saved);
    app.mount();
    assert.equal(app.button.attributes['aria-pressed'], String(saved === 'dark'));
    app.system(saved === 'light');
    assert.equal(app.root.dataset.theme, saved);
  }
});

test('toggle switches both ways and persists the chosen theme', () => {
  const app = setup({ dark: true });
  app.mount();
  app.click();
  assert.equal(app.storage.get('makerpanel-theme'), 'light');
  assert.equal(app.root.dataset.theme, 'light');
  assert.equal(app.button.title, 'Switch to dark mode');
  app.click();
  assert.equal(app.storage.get('makerpanel-theme'), 'dark');
  assert.equal(app.button.title, 'Switch to light mode');
  assert.equal(app.root.dataset.theme, 'dark');
  app.system(false);
  assert.equal(app.root.dataset.theme, 'dark');
});

test('invalid preferences and blocked storage degrade gracefully', () => {
  const invalid = setup({ saved: 'unexpected', dark: true });
  invalid.mount();
  assert.equal(invalid.root.dataset.theme, 'dark');
  const blocked = setup({ blocked: true, dark: true });
  blocked.mount();
  blocked.click();
  assert.equal(blocked.root.dataset.theme, 'light');
  blocked.click();
  assert.equal(blocked.root.dataset.theme, 'dark');
});

test('cross-tab changes sync preferences and storage clear restores System', () => {
  const app = setup();
  app.mount();
  app.sync('makerpanel-theme', 'dark');
  assert.equal(app.root.dataset.theme, 'dark');
  assert.equal(app.button.attributes['aria-pressed'], 'true');
  app.sync('unrelated', 'light');
  assert.equal(app.root.dataset.theme, 'dark');
  app.sync(null, null);
  assert.equal(app.button.attributes['aria-pressed'], 'false');
  assert.equal(app.root.dataset.theme, 'light');
});