/* Runs before styles load to avoid flashing the wrong saved theme. */
(() => {
  'use strict';
  const key = 'makerpanel-theme';
  const system = matchMedia('(prefers-color-scheme: dark)');
  const normalize = value => ['light', 'dark'].includes(value) ? value : 'system';
  let preference = 'system';
  try {
    preference = normalize(localStorage.getItem(key));
  } catch {
    // Storage may be unavailable; system defaults and local changes still work.
  }

  const apply = () => {
    const theme = preference === 'system'
      ? (system.matches ? 'dark' : 'light') : preference;
    document.documentElement.dataset.theme = theme;
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.content = theme === 'dark' ? '#171c18' : '#f3f1e9';
    document.querySelectorAll('[data-theme-toggle]').forEach(button => {
      button.setAttribute('aria-pressed', String(theme === 'dark'));
      button.title = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
    });
  };
  apply();
  system.addEventListener('change', apply);
  window.addEventListener('storage', event => {
    if (event.key === key || event.key === null) {
      preference = normalize(event.newValue);
      apply();
    }
  });
  document.addEventListener('DOMContentLoaded', () => {
    apply();
    document.querySelectorAll('[data-theme-toggle]').forEach(button => {
      button.hidden = false;
      button.addEventListener('click', () => {
        preference = document.documentElement.dataset.theme === 'dark'
          ? 'light' : 'dark';
        try {
          localStorage.setItem(key, preference);
        } catch {
          // Keep the selection usable even when persistence is blocked.
        }
        apply();
      });
    });
  });
})();