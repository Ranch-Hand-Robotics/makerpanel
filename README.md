<!-- Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

# Makerpanel

**Specification and Gallery of Maker Panels**

![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)

## Overview

Makerpanel is an open specification for modular control panels designed for makers, DIY enthusiasts, and electronics projects. Based on the Eurotrack synthesizer standard but adapted with **T-slot compatible rails** for universal mounting, Makerpanel provides a flexible framework for building custom control interfaces.

## Features

- **Universal Mounting System**: Uses standard T-slot rails with M5/M6 twist nuts for universal mounting
- **Modular Design**: Mix and match panels for your specific needs
- **Community Driven**: Open specification allowing anyone to design and share panels
- **Gallery of Designs**: Browse and download community-contributed panel designs

## Documentation

Visit our [documentation site](https://ranch-hand-robotics.github.io/makerpanel) for:

- **[Specification](https://ranch-hand-robotics.github.io/makerpanel/specification/)**: Detailed technical specifications for designing Makerpanel-compatible panels
- **[Gallery](https://ranch-hand-robotics.github.io/makerpanel/gallery/)**: Browse community-contributed panel designs
- **[Contributing](https://ranch-hand-robotics.github.io/makerpanel/contributing/)**: Submit your panel design using our easy form

## Quick Start

### Viewing the Documentation

The website uses MkDocs as a static publishing engine with a fully custom
HTML/CSS theme. No frontend framework or JavaScript bundler is required.

To view the documentation locally:

```bash
# Install dependencies
python -m pip install -r requirements.txt

# Serve locally
python -m mkdocs serve

# Build static site
python -m mkdocs build --strict
```

Open the local address printed by MkDocs.

### Working on the website

- `theme/main.html`: shared navigation, footer, and documentation layout.
- `theme/home.html`: editorial homepage; metadata lives in `docs/index.md`.
- `theme/assembly.svg`: original, illustrative hardware assembly, not a CAD
    drawing. Its exploded view is enhanced by `docs/js/site.js`.
- `docs/css/site.css`: responsive site styles, including reduced-motion rules.
- `docs/css/theme.css` and `docs/js/theme.js`: system-aware light/dark colors
    and a sun/moon toggle. Explicit choices persist in browser storage; without
    JavaScript, the palette follows the operating system.
- `docs/gallery.md` and `docs/js/gallery.js`: searchable gallery. Filters can be
    shared using `?q=keyboard`, `?category=Digital%20I%2FO`, and `?sort=width`.
- `.github/hooks.py`: existing build hook synchronizes the gallery catalog
    from `examples/`; a build can update `docs/gallery.json`.

Run the catalog, theme, and thumbnail unit tests with `npm test`
(Node.js 22 or newer). Before publishing, also run the strict build and check
desktop/mobile navigation, the exploded view, gallery filters, and docs links.
The home page and documentation work without JavaScript; the gallery includes
a direct source-directory fallback. Generated `site/` files are not committed.

### Generate gallery thumbnails

Thumbnail generation uses the Ranch Hand Robotics OpenSCAD WASM build, not
desktop OpenSCAD. Install Node.js 22+, the Python requirements above, and check
out submodules (`git submodule update --init --recursive`). Then run:

1. `npm ci`
2. `npx playwright install chromium` (Linux CI also needs `--with-deps`)
3. `npm run thumbnails:setup` downloads the checksum-pinned WASM release in
    `thumbnails.config.json`.
4. `npm run thumbnails` syncs the catalog through the existing MkDocs hook and
    generates both light and dark 800×520 PNGs.
5. `python -m mkdocs serve` previews the result, or `npm run build` generates
    thumbnails and builds the strict production site.

To use your own WASM build instead of downloading one, pass its directory:
`npm run thumbnails -- --wasm-dir ../babylon_ros/openscad-wasm-build/build`.
It must contain `openscad.js`, `openscad.wasm.js`, `openscad.wasm`, and
`openscad.fonts.js`. No environment variables or desktop OpenSCAD are required.
Use `--slug rail_panel` to regenerate one entry, or `--force` to bypass caching.
CLI options belong to `npm run thumbnails`, not `npm run build`.

**Source precedence**, configured per slug in `thumbnails.config.json`:

- An explicit `image` (repository-relative path) takes precedence. Existing
  non-placeholder `thumbnail` paths in `gallery.json` are also honored; local
  paths there are relative to `docs/`. Remote image URLs remain external and
  are not downloaded by the generator.
- Otherwise `scadFile` overrides the catalog's SCAD source. The generator
  preserves relative SVG/DXF imports and includes from `makerpanel/`,
  `examples/`, and `docs/panels/` in an isolated virtual filesystem.
- Optional `parameters` supplies scalar OpenSCAD `-D` overrides (for example,
  `{"part":"panel"}`); `module` calls a named no-argument module for files
  without a top-level object. `camera` sets a three-number viewing direction.
  CAD sources must be local, reviewed files; remote SCAD is not executed.

Uploaded images retain their colors and are fitted onto theme-matched
backgrounds. CAD is compiled to STL and rendered with a consistent lime material,
intentionally overriding **all** source colors rather than altering SCAD files.
These are design previews, not material or manufacturing guarantees.

The gallery reads `docs/images/panels/generated/manifest.json` and switches
image variants with the sun/moon control. The separate manifest survives MkDocs
catalog synchronization. Ordinary MkDocs builds never invoke CAD; without a
generated manifest the gallery uses supplied images or honest placeholders.

Source/assets, configuration, generator code, dependency lockfile, and WASM
bytes are fingerprinted. Unchanged previews are reused. Outputs and caches are
ignored by Git and generated in CI before the final MkDocs build. Errors are
recorded in `.cache/thumbnails/report.json`; missing inputs, empty geometry,
or timed-out renders fail the command instead of silently publishing success.
The Pages workflow runs on main pushes or manual dispatch and uploads the
diagnostic report. Panel-submission processing delegates generation to that
deployment workflow. To update the pinned WASM release, update both its URL
and SHA-256, then rerun `npm run thumbnails:setup`.

### Contributing

We welcome contributions!

- **[Submit your panel design](https://github.com/Ranch-Hand-Robotics/makerpanel/issues/new/choose)** — use our easy form, no Git required!
- Report bugs or suggest features
- Improve the specification or documentation

See our [Contributing Guide](https://ranch-hand-robotics.github.io/makerpanel/contributing/) for more details.

## Project Structure

```
makerpanel/
├── docs/                  # MkDocs documentation source
│   ├── index.md          # Home page
│   ├── specification.md  # Technical specification
│   ├── gallery.md        # Panel gallery
│   ├── contributing.md   # Contributing guide
│   ├── panels/           # Individual panel detail pages
│   │   ├── pot-panel.md
│   │   ├── led-panel.md
│   │   └── usb-panel.md
│   └── images/           # Images and thumbnails
│       └── panels/
├── mkdocs.yml            # MkDocs configuration
└── .github/
    └── workflows/
        └── deploy.yml    # GitHub Pages deployment workflow
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Inspired by the Eurotrack synthesizer module standard, reimagined for general maker applications.

---

**Maintained by**: [Ranch Hand Robotics](https://github.com/Ranch-Hand-Robotics)
