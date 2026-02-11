<!-- Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

# Contributing to Makerpanel

Thank you for your interest in contributing to the Makerpanel project! This guide will help you add your panel designs to the gallery.

## Ways to Contribute

You can contribute to Makerpanel in several ways:

1. **Submit a panel design** to the gallery
2. **Improve the specification** with clarifications or additions
3. **Report issues** with existing designs or documentation
4. **Suggest new features** or design guidelines

## Submitting a Panel Design

### Prerequisites

Before submitting your panel, ensure it:

- [ ] Follows the [Makerpanel Specification](specification.md)
- [ ] Includes clear mechanical drawings
- [ ] Has been tested or prototyped
- [ ] Includes proper documentation

### Required Files

Your panel submission should include:

1. **Thumbnail Image** (required)
   - Format: PNG, JPG, or SVG
   - Recommended size: 400×400 pixels minimum
   - File name: `your-panel-name-thumb.png` (or `.jpg`, `.svg`)
   - Place in: `docs/images/panels/`

2. **Detail Page** (required)
   - Format: Markdown (`.md`)
   - File name: `your-panel-name.md`
   - Place in: `docs/panels/`
   - See template below

3. **Design Files** (recommended)
   - Mechanical drawings (DXF, SVG, or PDF)
   - 3D models (STEP, STL, or FreeCAD)
   - Schematics (if electronic - PDF or KiCad)
   - Place in: `docs/files/panels/your-panel-name/`

4. **Bill of Materials** (recommended)
   - Format: CSV, Markdown table, or spreadsheet
   - Include part numbers and sources
   - Can be included in detail page or separate file

### Panel Detail Page Template

Create a new file `docs/panels/your-panel-name.md` with the following structure:

```markdown
---
title: Your Panel Name
category: Analog Control  # or: Visual Feedback, Connectivity, Digital I/O, Audio, Power
size: X HP × Y U
contributor: Your Name
thumbnail: images/panels/your-panel-name-thumb.png
description: Brief one-sentence description of your panel.
---

# Your Panel Name

![Panel Photo or Render](../images/panels/your-panel-name.jpg)

## Overview

Brief description of what your panel does and what it's used for.

## Purchase (Optional)

If available, include links to purchase the panel, kit, or parts and brief purchase details:

- Panel / Kit: [Vendor Name — Buy here](https://example.com)
- Parts kit: [Parts bundle](https://example.com/parts)
- Notes: Price, shipping, lead time, and warranty (if known)

## Specifications

- **Size**: X HP × Y U
- **Depth**: Z mm
- **Material**: [Aluminum/PCB/Acrylic/etc.]
- **Power Requirements**: [if applicable]
- **Mounting**: T-slot compatible (M5/M6 twist nuts)

## Features

- Feature 1
- Feature 2
- Feature 3

## Design Files

- [Mechanical Drawing (DXF)](../files/panels/your-panel-name/drawing.dxf)
- [3D Model (STEP)](../files/panels/your-panel-name/model.step)
- [Schematic (PDF)](../files/panels/your-panel-name/schematic.pdf)

## Bill of Materials

| Qty | Part | Description | Source |
|-----|------|-------------|--------|
| 1 | Panel | Aluminum 2mm | Custom fab |
| 4 | Pot | 10kΩ linear | Mouser |
| ... | ... | ... | ... |

## Assembly Instructions

1. Step 1
2. Step 2
3. Step 3

## Photos

![Photo 1](../images/panels/your-panel-name-1.jpg)
![Photo 2](../images/panels/your-panel-name-2.jpg)

## License

This design is released under [your chosen license, e.g., MIT, CC-BY-SA].

## Author

**Your Name**  
Contact: [your contact info or GitHub username]  
Date: Month Year
```

### Adding to Gallery

The gallery is automatically generated from panel files at build time. To add your panel:

1. Create your panel detail page in `docs/panels/your-panel-name.md` with proper front matter
2. Add your thumbnail image to `docs/images/panels/your-panel-name-thumb.png`
3. The gallery categories and statistics will be automatically updated

**Front matter fields**:
- `title`: Display name of the panel
- `category`: One of: Analog Control, Visual Feedback, Connectivity, Digital I/O, Audio, Power
- `size`: Panel dimensions (e.g., "8 HP × 3U")
- `contributor`: Your name or organization
- `thumbnail`: Path to thumbnail image (relative to docs/)
- `description`: One-sentence summary

### Submission Process

#### Option 1: Pull Request (Recommended)

1. Fork the repository
2. Create a new branch: `git checkout -b add-my-panel`
3. Add your files:
   - Thumbnail: `docs/images/panels/your-panel-name-thumb.png`
   - Detail page: `docs/panels/your-panel-name.md`
   - Design files: `docs/files/panels/your-panel-name/`
4. Update `docs/gallery.md` to include your panel
5. Commit your changes: `git commit -m "Add [Your Panel Name] to gallery"`
6. Push to your fork: `git push origin add-my-panel`
7. Open a Pull Request with:
   - Clear title: "Add [Your Panel Name] panel"
   - Description of your panel
   - Photos or renders
   - Any special notes

#### Option 2: Issue Submission

If you're not familiar with Git:

1. Open a new [GitHub Issue](https://github.com/Ranch-Hand-Robotics/makerpanel/issues/new)
2. Use the title: "Panel Submission: [Your Panel Name]"
3. Include in the issue:
   - Description of your panel
   - Thumbnail image
   - Links to design files (Google Drive, Dropbox, etc.)
   - All information from the template above
4. A maintainer will help integrate your submission

## Contributing to Specification

To propose changes to the specification:

1. Open an issue describing the proposed change
2. Discuss with the community
3. If approved, submit a pull request updating `docs/specification.md`
4. Include rationale and examples

## Design Guidelines

### Quality Standards

Submitted panels should:

- Be well-documented with clear instructions
- Include working design files (not just renders)
- Follow the Makerpanel specification
- Be original work or properly attributed

### Licensing

- You retain copyright to your designs
- Choose an open license (MIT, CC-BY-SA, etc.) to allow others to use and modify
- Clearly state the license in your detail page
- Respect others' intellectual property

### Image Guidelines

- Use high-quality images (minimum 400×400px for thumbnails)
- Show the actual panel or a realistic render
- Include photos from multiple angles when possible
- Ensure images are well-lit and in focus

## Community Standards

### Code of Conduct

- Be respectful and constructive
- Welcome newcomers and help them learn
- Give credit where credit is due
- Focus on collaboration over competition

### Getting Help

- Check existing issues and documentation first
- Ask clear, specific questions
- Provide context and examples
- Be patient and respectful

## Questions?

If you have questions about contributing:

- Check the [Specification](specification.md)
- Browse existing [panel submissions](gallery.md)
- Open an [issue](https://github.com/Ranch-Hand-Robotics/makerpanel/issues) for help
- Join the discussion in existing issues and pull requests

## Thank You!

Your contributions make Makerpanel better for everyone. We appreciate your time and creativity!

---

**Maintainers**: Ranch Hand Robotics  
**Last Updated**: January 2026
