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

The documentation is built with [MkDocs](https://www.mkdocs.org/) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

To view the documentation locally:

```bash
# Install dependencies
pip install mkdocs-material mkdocs-glightbox

# Serve locally
mkdocs serve

# Build static site
mkdocs build
```

Then open http://localhost:8000 in your browser.

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
