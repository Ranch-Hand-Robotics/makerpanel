import { selectPanels, safeUrl, panelSize } from './gallery-data.mjs';
import { thumbnailVariants } from './gallery-thumbnails.mjs';

const root = document.querySelector('#gallery-root');
const form = document.querySelector('#gallery-filters');
const search = document.querySelector('#panel-search');
const category = document.querySelector('#panel-category');
const sort = document.querySelector('#panel-sort');
const count = document.querySelector('#gallery-count');
const reset = document.querySelector('#clear-filters');
const fallback = 'https://github.com/Ranch-Hand-Robotics/makerpanel/tree/main/examples';
let panels = [];
let thumbnails = {};

function applyThumbnailTheme() {
  const theme = document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light';
  root.querySelectorAll('img[data-light]').forEach(image => {
    const src = image.dataset[theme];
    if (image.getAttribute('src') !== src) image.src = src;
  });
}
new MutationObserver(applyThumbnailTheme).observe(document.documentElement, {
  attributes: true, attributeFilter: ['data-theme'],
});

function element(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function blueprint(panel) {
  const drawing = element('div', 'panel-blueprint');
  drawing.setAttribute('aria-hidden', 'true');
  const initials = String(panel.title || panel.slug || 'MP').split(/\s+/)
    .slice(0, 2).map((word) => word[0]).join('').toUpperCase();
  drawing.append(element('span', '', initials), element('small', '', 'Preview pending'));
  return drawing;
}

function card(panel) {
  const title = panel.title || panel.slug || 'Untitled panel';
  const article = element('article', 'panel-card');
  const href = safeUrl(panel.panel_url, fallback, location.href);
  const visual = element('a', 'panel-card__image');
  visual.href = href;
  visual.setAttribute('aria-label', `Explore ${title}`);
  const variants = thumbnailVariants(panel, thumbnails);
  if (variants) {
    const image = element('img');
    image.dataset.light = safeUrl(variants.light, 'images/mark.svg', location.href);
    image.dataset.dark = safeUrl(variants.dark, 'images/mark.svg', location.href);
    image.src = image.dataset[document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light'];
    image.alt = `${title} preview`;
    image.loading = 'lazy';
    image.width = 800;
    image.height = 520;
    image.addEventListener('error', () => visual.replaceChildren(blueprint(panel)), { once: true });
    visual.append(image);
  } else {
    visual.append(blueprint(panel));
  }
  const body = element('div', 'panel-card__body');
  const heading = element('h2');
  const link = element('a', '', title);
  link.href = href;
  heading.append(link);
  const bottom = element('div', 'panel-card__bottom');
  const source = element('a', '', 'Explore files ↗');
  source.href = href;
  bottom.append(element('span', '', panelSize(panel)), source);
  body.append(element('span', 'panel-card__category', panel.category || 'Other'), heading,
    element('p', '', panel.description || 'Explore the design and source files for this panel.'), bottom);
  if (panel.buy_url) {
    const buy = element('a', 'panel-card__buy', 'Visit seller ↗');
    buy.href = safeUrl(panel.buy_url, fallback, location.href);
    body.append(buy);
  }
  article.append(visual, body);
  return article;
}

function readFilters() {
  const params = new URLSearchParams(location.search);
  search.value = params.get('q') || '';
  category.value = params.get('category') || '';
  if (!category.value) category.value = '';
  sort.value = params.get('sort') === 'width' ? 'width' : 'title';
}

function render(updateUrl = true) {
  const state = { query: search.value, category: category.value, sort: sort.value };
  const selected = selectPanels(panels, state);
  count.textContent = `${selected.length} of ${panels.length} panels / Open to explore`;
  reset.hidden = !(state.query || state.category || state.sort !== 'title');
  root.className = selected.length ? 'panel-grid' : 'empty-gallery';
  if (selected.length) {
    root.replaceChildren(...selected.map(card));
  } else {
    root.replaceChildren(element('h2', '', 'Room for another idea.'),
      element('p', '', 'No panels match these filters. Try another term or clear the filters.'));
  }
  if (updateUrl) {
    const url = new URL(location.href);
    for (const [name, value] of Object.entries({ q: state.query, category: state.category,
      sort: state.sort === 'title' ? '' : state.sort })) {
      if (value) url.searchParams.set(name, value);
      else url.searchParams.delete(name);
    }
    history.replaceState(null, '', url);
  }
}

async function loadGallery() {
  try {
    const response = await fetch('./gallery.json');
    if (!response.ok) throw new Error(`Catalog request failed: ${response.status}`);
    const payload = await response.json();
    if (!Array.isArray(payload.panels)) throw new Error('Invalid catalog');
    panels = payload.panels.filter((panel) => panel && typeof panel === 'object');
    // A plain MkDocs preview without generated assets still has a usable gallery.
    try {
      const previews = await fetch('./images/panels/generated/manifest.json');
      if (previews.ok) thumbnails = await previews.json();
    } catch {
      thumbnails = {};
    }
    const categories = [...new Set(panels.map((panel) => panel.category || 'Other'))].sort();
    for (const value of categories) {
      const option = element('option', '', value);
      option.value = value;
      category.append(option);
    }
    readFilters();
    render(false);
    form.hidden = false;
  } catch (error) {
    console.error('Unable to load panel catalog:', error);
    root.className = 'empty-gallery';
    const link = element('a', 'text-link', 'Browse source files on GitHub ↗');
    link.href = fallback;
    root.replaceChildren(element('h2', '', 'The catalog couldn’t connect.'),
      element('p', '', 'Your next build is still out there. Explore the source files or try again.'), link);
    count.textContent = 'Catalog unavailable';
  } finally {
    root.setAttribute('aria-busy', 'false');
  }
}

form.addEventListener('submit', (event) => event.preventDefault());
search.addEventListener('input', () => render());
category.addEventListener('change', () => render());
sort.addEventListener('change', () => render());
reset.addEventListener('click', () => {
  search.value = '';
  category.value = '';
  sort.value = 'title';
  render();
  search.focus();
});
window.addEventListener('popstate', () => { readFilters(); render(false); });
loadGallery();