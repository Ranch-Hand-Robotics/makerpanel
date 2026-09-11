import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import AdmZip from 'adm-zip';

const root = fileURLToPath(new URL('../../', import.meta.url));
const { wasm } = JSON.parse(await readFile(path.join(root, 'thumbnails.config.json')));
const target = path.join(root, '.cache/thumbnails/wasm');
const response = await fetch(wasm.url, { signal: AbortSignal.timeout(120000) });
if (!response.ok) throw new Error(`WASM download failed: HTTP ${response.status}`);
const bytes = Buffer.from(await response.arrayBuffer());
if (createHash('sha256').update(bytes).digest('hex') !== wasm.sha256) {
  throw new Error('WASM checksum mismatch; update the pinned release deliberately.');
}
const zip = new AdmZip(bytes);
await mkdir(target, { recursive: true });
for (const name of ['openscad.js', 'openscad.wasm.js', 'openscad.wasm', 'openscad.fonts.js']) {
  const entry = zip.getEntries().find(e => !e.isDirectory && path.posix.basename(e.entryName) === name);
  if (!entry || entry.header.size === 0) throw new Error(`Missing runtime file: ${name}`);
  await writeFile(path.join(target, name), entry.getData());
}
console.log(`Verified OpenSCAD WASM installed in ${target}`);