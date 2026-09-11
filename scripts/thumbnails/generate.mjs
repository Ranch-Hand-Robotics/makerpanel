import { readFile, writeFile, mkdir, readdir, stat, rename, realpath, unlink } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { createServer } from 'node:http';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import path from 'node:path';
import { chromium } from 'playwright';
import sharp from 'sharp';
import { containedPath, sourceFor, overrideArgs } from './lib.mjs';

const root = fileURLToPath(new URL('../../', import.meta.url));
const scripts = path.join(root, 'scripts/thumbnails');
const { values: options } = parseArgs({ options: {
  'wasm-dir': { type: 'string' }, slug: { type: 'string' },
  force: { type: 'boolean', default: false },
} });
const config = JSON.parse(await readFile(path.join(root, 'thumbnails.config.json')));
const catalog = JSON.parse(await readFile(path.join(root, 'docs/gallery.json')));
const outputDir = path.join(root, 'docs/images/panels/generated');
const cacheDir = path.join(root, '.cache/thumbnails');
const wasmDir = path.resolve(root, options['wasm-dir'] || '.cache/thumbnails/wasm');
const manifestPath = path.join(outputDir, 'manifest.json');
const reportPath = path.join(cacheDir, 'report.json');
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
async function exists(file) { try { return (await stat(file)).isFile(); } catch { return false; } }
async function loadJson(file, fallback) {
  try { return JSON.parse(await readFile(file)); }
  catch (error) { if (error.code === 'ENOENT') return fallback; throw error; }
}
async function atomicJson(file, data) {
  await writeFile(`${file}.tmp`, JSON.stringify(data, null, 2) + '\n');
  await rename(`${file}.tmp`, file);
}
await mkdir(outputDir, { recursive: true });
await mkdir(cacheDir, { recursive: true });
const manifest = await loadJson(manifestPath, { version: 1, panels: {} });
const report = [];
const allPanels = catalog.panels;
const panels = allPanels.filter(p => !options.slug || p.slug === options.slug);
if (!panels.length) throw new Error(`No panel found: ${options.slug || '(empty catalog)'}`);
for (const slug of Object.keys(manifest.panels)) {
  if (!allPanels.some(p => p.slug === slug)) delete manifest.panels[slug];
}

// Serve an explicit allowlist, never the repository or arbitrary filesystem paths.
const assets = new Map();
const inputs = new Map();
const extensions = new Set(['.scad', '.svg', '.dxf', '.off', '.dat', '.stl']);
async function collect(dir) {
  if (!await stat(dir).catch(() => null)) return;
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('.') || entry.isSymbolicLink()) continue;
    const file = path.join(dir, entry.name);
    if (entry.isDirectory()) await collect(file);
    else if (entry.isFile() && extensions.has(path.extname(file).toLowerCase())) {
      if ((await stat(file)).size > 50 * 1024 * 1024) throw new Error(`Asset too large: ${file}`);
      const relative = path.relative(root, file).split(path.sep).join('/');
      inputs.set(relative, await readFile(file));
    }
  }
}
for (const folder of ['makerpanel', 'examples', 'docs/panels']) await collect(path.join(root, folder));
// Resolve includes to stable VFS paths without relying on a desktop library path.
for (const [name, bytes] of inputs) {
  if (!name.endsWith('.scad')) continue;
  const source = bytes.toString('utf8').replace(/\b(include|use)\s*<([^>]+)>/g, (full, directive, ref) => {
    const candidates = [path.posix.join(path.posix.dirname(name), ref), ref, `makerpanel/${ref}`];
    const found = candidates.find(candidate => inputs.has(candidate));
    return found ? `${directive} </workspace/${found}>` : full;
  });
  inputs.set(name, Buffer.from(source));
}
const assetHash = createHash('sha256');
for (const [name, bytes] of [...inputs].sort(([a], [b]) => a.localeCompare(b))) assetHash.update(name).update(bytes);
const inputFingerprint = assetHash.digest('hex');
const scriptHash = createHash('sha256');
for (const name of (await readdir(scripts)).sort()) scriptHash.update(await readFile(path.join(scripts, name)));
scriptHash.update(await readFile(path.join(root, 'package-lock.json')));
const rendererFingerprint = scriptHash.digest('hex');

let browser;
let server;
let origin;
let runtimeFingerprint;
async function ensureRenderer() {
  if (browser) return;
  const runtimeHash = createHash('sha256');
  for (const name of ['openscad.js', 'openscad.wasm.js', 'openscad.wasm', 'openscad.fonts.js']) {
    const file = path.join(wasmDir, name);
    if (!await exists(file)) throw new Error(`Missing ${file}. Run npm run thumbnails:setup or pass --wasm-dir.`);
    const bytes = await readFile(file);
    runtimeHash.update(bytes);
    assets.set(`/wasm/${name}`, bytes);
  }
  runtimeFingerprint = runtimeHash.digest('hex');
  for (const name of ['viewer.html', 'viewer.css', 'viewer.js', 'worker.js']) assets.set(`/${name}`, await readFile(path.join(scripts, name)));
  for (const name of ['build/three.module.js', 'build/three.core.js', 'examples/jsm/loaders/STLLoader.js']) {
    assets.set(`/three/${name}`, await readFile(path.join(root, 'node_modules/three', name)));
  }
  const paths = [];
  for (const [name, bytes] of inputs) {
    const url = `/input/${paths.length}`;
    assets.set(url, bytes);
    paths.push([`/workspace/${name}`, url]);
  }
  assets.set('/inputs.json', Buffer.from(JSON.stringify(paths)));
  const mime = { '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.css': 'text/css', '.html': 'text/html' };
  server = createServer((request, response) => {
    const url = new URL(request.url, 'http://localhost').pathname;
    const bytes = assets.get(url);
    if (!bytes) { response.writeHead(404); response.end(); return; }
    response.writeHead(200, {
      'Content-Type': mime[path.extname(url)] || 'application/octet-stream',
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    });
    response.end(bytes);
  });
  await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
  origin = `http://127.0.0.1:${server.address().port}`;
  browser = await chromium.launch({ headless: true, args: ['--enable-unsafe-swiftshader'] });
}

try {
  for (const panel of panels) {
    let page;
    try {
      if (!/^[a-z0-9_-]+$/i.test(panel.slug)) throw new Error('Invalid panel slug');
      const override = config.panels[panel.slug] || {};
      if (override.module && !/^[A-Za-z_][\w]*$/.test(override.module)) {
        throw new Error('Invalid preview module name');
      }
      const source = sourceFor(panel, override);
      if (source.type === 'remote') {
        delete manifest.panels[panel.slug];
        report.push({ slug: panel.slug, status: 'uploaded-remote', source: source.path });
        continue;
      }
      const file = containedPath(root, source.path);
      // Reject symlinks escaping the checkout, including local uploads.
      containedPath(root, path.relative(root, await realpath(file)));
      const bytes = await readFile(file);
      if (source.type === 'scad') await ensureRenderer();
      const fingerprint = hash(JSON.stringify({
        source, override, config, rendererFingerprint,
        input: source.type === 'scad' ? inputFingerprint : hash(bytes),
        runtime: source.type === 'scad' ? runtimeFingerprint : null,
      }));
      const old = manifest.panels[panel.slug];
      if (!options.force && old?.fingerprint === fingerprint &&
          await exists(path.join(root, 'docs', old.light)) && await exists(path.join(root, 'docs', old.dark))) {
        console.log(`[thumbnail] cached ${panel.slug}`);
        report.push({ slug: panel.slug, status: 'cached' });
        continue;
      }
      let renderInfo;
      if (source.type === 'scad') {
        page = await browser.newPage({ viewport: { width: config.width, height: config.height } });
        await page.goto(`${origin}/viewer.html`);
        await page.waitForFunction(() => typeof window.compile === 'function');
        renderInfo = await page.evaluate(data => window.compile(data), {
          input: `/workspace/${source.path.replaceAll('\\', '/')}`,
          args: overrideArgs({ $fn: 32, ...override.parameters }),
          width: config.width, height: config.height, timeoutMs: config.timeoutMs,
          camera: override.camera,
          module: override.module,
        });
      }
      const entry = { fingerprint, source: source.path, type: source.type };
      for (const theme of ['light', 'dark']) {
        const name = `${panel.slug}-${fingerprint.slice(0, 12)}-${theme}.png`;
        const file = path.join(outputDir, name);
        if (source.type === 'image') {
          await sharp(bytes).rotate().resize(config.width, config.height, {
            fit: 'contain', background: config.themes[theme].background,
          }).flatten({ background: config.themes[theme].background }).png().toFile(file);
        } else {
          await page.evaluate(theme => window.renderTheme(theme), config.themes[theme]);
          await page.locator('canvas').screenshot({ path: file });
        }
        entry[theme] = `images/panels/generated/${name}`;
      }
      manifest.panels[panel.slug] = entry;
      report.push({ slug: panel.slug, status: 'generated', source, ...renderInfo });
      console.log(`[thumbnail] ${source.type}: ${panel.slug}`);
    } catch (error) {
      // Never advertise stale geometry after a failed regeneration.
      delete manifest.panels[panel.slug];
      report.push({ slug: panel.slug, status: 'failed', error: error.message });
      console.error(`[thumbnail] FAILED ${panel.slug}: ${error.message}`);
    } finally { await page?.close(); }
  }
} finally {
  await browser?.close();
  if (server) await new Promise(resolve => server.close(resolve));
  await atomicJson(manifestPath, manifest);
  await atomicJson(reportPath, report);
  // Only prune our hash-named artifacts; never touch uploaded/user-named files.
  const retained = new Set(Object.values(manifest.panels).flatMap(entry =>
    [path.posix.basename(entry.light), path.posix.basename(entry.dark)]));
  for (const name of await readdir(outputDir)) {
    if (/^[a-z0-9_-]+-[a-f0-9]{12}-(?:light|dark)\.png$/i.test(name) && !retained.has(name)) {
      await unlink(path.join(outputDir, name));
    }
  }
}
const failures = report.filter(item => item.status === 'failed');
console.log(`[thumbnail] ${report.length} processed; ${failures.length} failed. Report: ${reportPath}`);
if (failures.length) process.exitCode = 1;