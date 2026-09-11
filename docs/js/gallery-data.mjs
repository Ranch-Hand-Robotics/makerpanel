/* Pure catalog helpers shared by the browser and dependency-free tests. */
export function selectPanels(panels, { query = '', category = '', sort = 'title' } = {}) {
  const words = query.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean);
  return panels.filter((panel) => {
    const text = [panel.title, panel.slug, panel.description, panel.category]
      .filter(Boolean).join(' ').toLocaleLowerCase();
    return (!category || (panel.category || 'Other') === category)
      && words.every((word) => text.includes(word));
  }).sort((a, b) => {
    if (sort === 'width') {
      const width = (panel) => Number.isFinite(panel.horizontalPitch)
        && panel.horizontalPitch > 0 ? panel.horizontalPitch : Infinity;
      const difference = width(a) - width(b);
      if (difference && Number.isFinite(difference)) return difference;
      if (width(a) !== width(b)) return width(a) === Infinity ? 1 : -1;
    }
    return String(a.title || a.slug || '').localeCompare(String(b.title || b.slug || ''));
  });
}

export function safeUrl(candidate, fallback, base) {
  try {
    const url = new URL(candidate || fallback, base);
    if (['https:', 'http:'].includes(url.protocol)) return url.href;
  } catch { /* Use the known fallback for invalid catalog links. */ }
  return new URL(fallback, base).href;
}

export function panelSize(panel) {
  const hp = panel.horizontalPitch;
  const u = panel.verticalUnits;
  if (!(Number.isFinite(hp) && hp > 0 && Number.isFinite(u) && u > 0)) {
    return 'Dimensions in source';
  }
  return `${hp} HP / ${u}U`;
}