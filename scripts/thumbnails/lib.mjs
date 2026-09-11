import path from 'node:path';

export function containedPath(root, relative) {
  if (typeof relative !== 'string' || !relative || path.isAbsolute(relative)) {
    throw new Error(`Expected a relative local path: ${relative}`);
  }
  const resolved = path.resolve(root, relative);
  if (!resolved.startsWith(path.resolve(root) + path.sep)) {
    throw new Error(`Path escapes root: ${relative}`);
  }
  return resolved;
}

export function isPlaceholder(value = '') {
  return !value || /(?:^|\/)(?:makerpanel\.(?:png|jpg)|makericon\.)/i.test(value);
}

export function sourceFor(panel, override = {}) {
  if (override.image) return { type: 'image', path: override.image };
  if (!isPlaceholder(panel.thumbnail) && !panel.thumbnail.includes('/generated/')) {
    if (/^https?:\/\//i.test(panel.thumbnail)) return { type: 'remote', path: panel.thumbnail };
    return { type: 'image', path: `docs/${panel.thumbnail}` };
  }
  return { type: 'scad', path: override.scadFile || panel.scadFile };
}

export function overrideArgs(parameters = {}) {
  return Object.entries(parameters).flatMap(([key, value]) => {
    if (!/^[A-Za-z_$][\w$]*$/.test(key) ||
        !['string', 'number', 'boolean'].includes(typeof value) ||
        (typeof value === 'number' && !Number.isFinite(value))) {
      throw new Error(`Invalid SCAD parameter: ${key}`);
    }
    return ['-D', `${key}=${JSON.stringify(value)}`];
  });
}