/* Progressive enhancement: links and the assembly remain useful without JS. */
(() => {
  'use strict';
  const toggle = document.querySelector('.nav-toggle');
  const nav = document.querySelector('#main-nav');
  if (toggle && nav) {
    toggle.hidden = false;
    document.documentElement.classList.add('nav-enhanced');
    const closeMenu = () => {
      toggle.setAttribute('aria-expanded', 'false');
      nav.classList.remove('is-open');
    };
    toggle.addEventListener('click', () => {
      const open = toggle.getAttribute('aria-expanded') !== 'true';
      toggle.setAttribute('aria-expanded', String(open));
      nav.classList.toggle('is-open', open);
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
        closeMenu();
        toggle.focus();
      }
    });
    nav.addEventListener('click', (event) => {
      if (event.target.closest('a')) closeMenu();
    });
    matchMedia('(min-width: 1101px)').addEventListener('change', closeMenu);
  }
  const assembly = document.querySelector('[data-assembly]');
  const assemblyToggle = assembly?.querySelector('.assembly-toggle');
  if (assemblyToggle) {
    assemblyToggle.hidden = false;
    assemblyToggle.addEventListener('click', () => {
      const exploded = assembly.classList.toggle('is-exploded');
      assemblyToggle.setAttribute('aria-pressed', String(exploded));
      assemblyToggle.querySelector('[data-assembly-label]').textContent = exploded
        ? 'Assemble view' : 'Explode view';
      assembly.querySelector('#assembly-description').textContent = exploded
        ? 'Independent panels. Shared mounting rails.'
        : 'Different functions. One shared foundation.';
    });
  }
})();