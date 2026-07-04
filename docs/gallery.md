---
hide:
  - navigation
  - toc
title: Gallery
---
<!-- Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

<div class="gallery-hero" style="text-align: center; padding: 3rem 2rem 2rem; position: relative; overflow: hidden; background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 50%, #1a1a1a 100%); border-radius: 0; margin: -1rem -2rem 2rem; border-bottom: 2px solid #4a9d5f;">
  <div style="position: relative; z-index: 1;">
    <h1 style="font-size: 3.5rem; font-weight: 900; margin-bottom: 0.75rem; color: #4a9d5f; letter-spacing: 0.05em; font-family: 'Courier New', monospace;">
      > Maker Panels
    </h1>
    <p style="font-size: 1.4rem; color: #b0b0b0; margin-bottom: 2rem; font-weight: 400;">
      Browse community-contributed panel designs, download files, and get inspired for your next project
    </p>
    <a href="https://github.com/Ranch-Hand-Robotics/makerpanel/issues/new?template=submit-panel.yml" class="gallery-cta" style="background: #4a9d5f; color: #ffffff; padding: 1rem 2.5rem; border-radius: 0.25rem; text-decoration: none; font-weight: 900; font-size: 1.1rem; display: inline-block; transition: all 0.3s ease; border: 2px solid #4a9d5f; text-transform: uppercase; letter-spacing: 0.1em;">
      + Submit Panel
    </a>
  </div>
</div>

---

<!-- CATEGORY_TABS_START -->
<div id="gallery-root" aria-live="polite" style="padding: 1rem 0; color: #b0b0b0;">Loading gallery...</div>

<script>
(() => {
  const root = document.getElementById('gallery-root');
  const stats = document.getElementById('gallery-stats');

  const escapeHtml = (value) => String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

  const panelCard = (panel) => {
    const title = escapeHtml(panel.title || panel.slug || 'Untitled Panel');
    const panelUrl = escapeHtml(panel.panel_url || `panels/${panel.slug || ''}/index.html`);
    const thumb = escapeHtml(panel.thumbnail || 'images/panels/placeholder.svg');
    const description = escapeHtml(panel.description || '');
    const buyUrl = (panel.buy_url || '').trim();
    const buyBadge = buyUrl
      ? `<a class="panel-card__buy" href="${escapeHtml(buyUrl)}" target="_blank" rel="noopener noreferrer">Buy Now</a>`
      : '';

    return `<div class="panel-card">
      <a href="${panelUrl}" data-title="${title}"><img src="${thumb}" alt="${title}" /></a>
      ${buyBadge}
      <p>${description}</p>
    </div>`;
  };

  const render = (panels) => {
    const sortedPanels = [...panels].sort((a, b) => (a.title || '').localeCompare(b.title || ''));
    const categories = [...new Set(sortedPanels.map(p => p.category || 'Other'))].sort();
    const tabNames = ['All', ...categories];

    const radioInputs = tabNames
      .map((name, index) => `<input ${index === 0 ? 'checked="checked" ' : ''}id="tab_${index + 1}" name="tabs" type="radio" />`)
      .join('');

    const labels = tabNames
      .map((name, index) => `<label for="tab_${index + 1}">${escapeHtml(name)}</label>`)
      .join('\n');

    const allCards = sortedPanels.map(panelCard).join('\n');
    const categoryBlocks = categories.map((category) => {
      const cards = sortedPanels
        .filter((panel) => (panel.category || 'Other') === category)
        .map(panelCard)
        .join('\n');
      return `<div class="tabbed-block">${cards}</div>`;
    }).join('\n');

    root.innerHTML = `<div class="tabbed-set tabbed-alternate">\n${radioInputs}\n<div class="tabbed-labels">\n${labels}\n</div>\n<div class="tabbed-content">\n<div class="tabbed-block">${allCards}</div>\n${categoryBlocks}\n</div>\n</div>`;

    if (stats) {
      const contributors = new Set(sortedPanels.map((p) => p.contributor || 'Community'));
      stats.innerHTML = `${sortedPanels.length} panels &middot; ${contributors.size} contributors &middot; ${categories.length} categories`;
    }
  };

  fetch('./gallery.json', { cache: 'no-store' })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return response.json();
    })
    .then((payload) => {
      const panels = Array.isArray(payload?.panels) ? payload.panels : [];
      if (!panels.length) {
        root.innerHTML = '<p>No panels available yet. Be the first to submit one!</p>';
        if (stats) {
          stats.textContent = '0 panels · 0 contributors · 0 categories';
        }
        return;
      }
      render(panels);
    })
    .catch((error) => {
      console.error('Failed to load gallery.json:', error);
      root.innerHTML = '<p>Unable to load gallery data right now. Please try again shortly.</p>';
      if (stats) {
        stats.textContent = 'Gallery data unavailable';
      }
    });
})();
</script>
<!-- CATEGORY_TABS_END -->

<div style="margin: 2rem 0 0.5rem; color: #606060; font-size: 0.8rem;">
  <span id="gallery-stats">Loading panel stats...</span>
</div>

**Questions?** 

[Submit your panel](https://github.com/Ranch-Hand-Robotics/makerpanel/issues/new/choose) or ask on [GitHub Discussions](https://github.com/Ranch-Hand-Robotics/makerpanel/discussions).
