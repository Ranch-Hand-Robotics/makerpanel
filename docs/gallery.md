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

  let openscadModulePromise = null;
  let supportFilesPromise = null;

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
    const slug = escapeHtml(panel.slug || '');
    const buyUrl = (panel.buy_url || '').trim();
    const buyBadge = buyUrl
      ? `<a class="panel-card__buy" href="${escapeHtml(buyUrl)}" target="_blank" rel="noopener noreferrer">Buy Now</a>`
      : '';

    return `<div class="panel-card">
      <a href="${panelUrl}" data-title="${title}"><img data-thumb-slug="${slug}" src="${thumb}" alt="${title}" /></a>
      ${buyBadge}
      <p>${description}</p>
    </div>`;
  };

  const toRawGithubUrl = (url) => {
    if (!url) {
      return '';
    }

    const text = String(url).trim();
    if (/^https:\/\/raw\.githubusercontent\.com\//i.test(text)) {
      return text;
    }

    const treeMatch = text.match(/^https:\/\/github\.com\/([^/]+)\/([^/]+)\/tree\/([^/]+)\/(.+)$/i);
    if (treeMatch) {
      const [, owner, repo, ref, path] = treeMatch;
      return `https://raw.githubusercontent.com/${owner}/${repo}/${ref}/${path}`;
    }

    return text;
  };

  const getRepoRawRoot = (rawUrl) => {
    const match = String(rawUrl || '').match(/^https:\/\/raw\.githubusercontent\.com\/([^/]+)\/([^/]+)\/([^/]+)\//i);
    if (!match) {
      return '';
    }

    const [, owner, repo, ref] = match;
    return `https://raw.githubusercontent.com/${owner}/${repo}/${ref}`;
  };

  const isRemoteHttpUrl = (value) => /^https?:\/\//i.test(String(value || ''));

  const getDirectoryFromRawFileUrl = (rawFileUrl) => {
    const idx = rawFileUrl.lastIndexOf('/');
    return idx >= 0 ? rawFileUrl.slice(0, idx) : rawFileUrl;
  };

  const joinUrl = (base, relativePath) => {
    if (!base) {
      return relativePath;
    }
    if (/^https?:\/\//i.test(relativePath)) {
      return relativePath;
    }
    const cleanedBase = base.replace(/\/+$/, '');
    const cleanedRel = String(relativePath || '').replace(/^\/+/, '');
    return `${cleanedBase}/${cleanedRel}`;
  };

  const createOpenScadInstance = async () => {
    if (!openscadModulePromise) {
      openscadModulePromise = import('https://cdn.jsdelivr.net/npm/openscad-wasm@0.0.4/openscad.js');
    }

    const mod = await openscadModulePromise;
    return mod.createOpenSCAD({ noInitialRun: true });
  };

  const getSupportFiles = async (repoRawRoot) => {
    if (!supportFilesPromise) {
      const filePaths = [
        'makerpanel/common.scad',
        'makerpanel/panel.scad',
        'makerpanel/rack.scad',
        'makerpanel/rails.scad',
        'makerpanel/rails_laser.scad',
      ];

      supportFilesPromise = Promise.all(filePaths.map(async (path) => {
        const response = await fetch(joinUrl(repoRawRoot, path), { cache: 'force-cache' });
        if (!response.ok) {
          throw new Error(`Failed to fetch support file: ${path}`);
        }
        const text = await response.text();
        return { path, text };
      }));
    }
    return supportFilesPromise;
  };

  const getLocalSupportFiles = async () => {
    if (!supportFilesPromise) {
      const filePaths = [
        'generated/scad/makerpanel/common.scad',
        'generated/scad/makerpanel/panel.scad',
        'generated/scad/makerpanel/rack.scad',
        'generated/scad/makerpanel/rails.scad',
        'generated/scad/makerpanel/rails_laser.scad',
      ];

      supportFilesPromise = Promise.all(filePaths.map(async (path) => {
        const response = await fetch(path, { cache: 'force-cache' });
        if (!response.ok) {
          throw new Error(`Failed to fetch local support file: ${path}`);
        }
        const text = await response.text();
        return { path: path.replace('generated/scad/', ''), text };
      }));
    }
    return supportFilesPromise;
  };

  const ensureFsDir = (fs, path) => {
    const parts = String(path || '').split('/').filter(Boolean);
    let current = '';
    for (const part of parts) {
      current += `/${part}`;
      try {
        fs.mkdir(current);
      } catch (_) {
        // Directory already exists.
      }
    }
  };

  const writeFsText = (fs, filePath, text) => {
    const normalized = String(filePath || '').replace(/^\/+/, '');
    const dir = normalized.includes('/') ? normalized.slice(0, normalized.lastIndexOf('/')) : '';
    if (dir) {
      ensureFsDir(fs, dir);
    }
    fs.writeFile(`/${normalized}`, text);
  };

  const parseImportAssetPaths = (code) => {
    const assets = new Set();
    const importRegex = /\bimport\s*\(\s*"([^"]+)"\s*(?:,|\))/g;
    let match;
    while ((match = importRegex.exec(code)) !== null) {
      const assetPath = match[1].trim();
      if (assetPath && !assetPath.includes('://')) {
        assets.add(assetPath);
      }
    }
    return [...assets];
  };

  const renderStlToImageDataUrl = async (stlText) => {
    const THREE = await import('https://esm.sh/three@0.164.1');
    const { STLLoader } = await import('https://esm.sh/three@0.164.1/examples/jsm/loaders/STLLoader.js');

    const width = 640;
    const height = 360;
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x111111);

    const camera = new THREE.PerspectiveCamera(35, width / height, 0.1, 5000);
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false, preserveDrawingBuffer: true });
    renderer.setSize(width, height, false);

    const ambient = new THREE.AmbientLight(0xcccccc, 0.65);
    const key = new THREE.DirectionalLight(0xffffff, 0.8);
    key.position.set(2, 3, 4);
    const fill = new THREE.DirectionalLight(0x88aa99, 0.35);
    fill.position.set(-2, -1, 2);
    scene.add(ambient, key, fill);

    const loader = new STLLoader();
    const geometry = loader.parse(stlText);
    geometry.computeVertexNormals();
    geometry.computeBoundingBox();

    const material = new THREE.MeshStandardMaterial({ color: 0x4a9d5f, metalness: 0.12, roughness: 0.75 });
    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    const box = geometry.boundingBox;
    const size = new THREE.Vector3();
    box.getSize(size);
    const center = new THREE.Vector3();
    box.getCenter(center);
    mesh.position.sub(center);

    const maxDim = Math.max(size.x, size.y, size.z) || 1;
    const distance = maxDim * 1.8;
    camera.position.set(distance, distance * 0.8, distance);
    camera.lookAt(0, 0, 0);
    camera.updateProjectionMatrix();

    renderer.render(scene, camera);
    const dataUrl = renderer.domElement.toDataURL('image/png');
    renderer.dispose();
    geometry.dispose();
    material.dispose();

    return dataUrl;
  };

  const renderScadThumbnail = async (panel) => {
    if (!panel?.scadFile) {
      return null;
    }

    const source = String(panel.scadFile || '').trim();
    const isRemote = isRemoteHttpUrl(source);
    const resolvedScadUrl = isRemote ? toRawGithubUrl(source) : source;
    const scadDir = getDirectoryFromRawFileUrl(resolvedScadUrl);
    const scadFilename = resolvedScadUrl.split('/').pop() || 'panel.scad';

    const supportFilesPromiseForSource = isRemote
      ? getSupportFiles(getRepoRawRoot(resolvedScadUrl))
      : getLocalSupportFiles();

    const [openScad, supportFiles, scadResponse] = await Promise.all([
      createOpenScadInstance(),
      supportFilesPromiseForSource,
      fetch(resolvedScadUrl, { cache: 'force-cache' }),
    ]);

    if (!scadResponse.ok) {
      throw new Error(`Failed to fetch SCAD source (${scadResponse.status})`);
    }

    const code = await scadResponse.text();
    const fs = openScad.getInstance().FS;

    for (const file of supportFiles) {
      writeFsText(fs, file.path, file.text);
    }

    // Convenience aliases for files included as <panel.scad> / <common.scad>
    const panelSupport = supportFiles.find((file) => file.path === 'makerpanel/panel.scad');
    const commonSupport = supportFiles.find((file) => file.path === 'makerpanel/common.scad');
    if (panelSupport) {
      writeFsText(fs, 'panel.scad', panelSupport.text);
    }
    if (commonSupport) {
      writeFsText(fs, 'common.scad', commonSupport.text);
    }

    const importAssets = parseImportAssetPaths(code);
    const explicitAssets = Array.isArray(panel.scadAssets) ? panel.scadAssets : [];
    const combinedAssets = [...new Set([...importAssets, ...explicitAssets])];
    for (const assetPath of combinedAssets) {
      const assetUrl = joinUrl(scadDir, assetPath);
      const assetResponse = await fetch(assetUrl, { cache: 'force-cache' });
      if (!assetResponse.ok) {
        // Ignore optional assets and rely on fallback thumbnail.
        continue;
      }
      const assetText = await assetResponse.text();
      writeFsText(fs, assetPath, assetText);
    }

    writeFsText(fs, scadFilename, code);
    writeFsText(fs, 'main.scad', code);

    const stl = await openScad.renderToStl(code);
    const dataUrl = await renderStlToImageDataUrl(stl);
    return dataUrl;
  };

  const hydrateScadThumbnails = async (panels) => {
    const scadPanels = panels.filter((panel) => panel && panel.scadFile);
    if (!scadPanels.length) {
      return;
    }

    for (const panel of scadPanels) {
      try {
        const dataUrl = await renderScadThumbnail(panel);
        if (!dataUrl) {
          continue;
        }

        const selector = `img[data-thumb-slug="${(panel.slug || '').replace(/"/g, '\\"')}"]`;
        const images = root.querySelectorAll(selector);
        for (const img of images) {
          img.src = dataUrl;
        }
      } catch (error) {
        // Keep fallback thumbnail if rendering fails.
        console.warn(`SCAD thumbnail generation failed for ${panel.slug || 'panel'}:`, error);
      }
    }
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
      hydrateScadThumbnails(panels);
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
