# Maker Panel KiCad Templates

This directory contains KiCad 8.0+ compatible PCB templates for the [Maker Panel](https://github.com/Ranch-Hand-Robotics/makerpanel) specification.

## Quick Start

When creating a new KiCad project, select **"Create from template"** and choose your desired Maker Panel size:

- **Maker Panel 4 HP** — 20.32 × 128.5 mm (compact)
- **Maker Panel 8 HP** — 40.64 × 128.5 mm (recommended)
- **Maker Panel 12 HP** — 60.96 × 128.5 mm (multi-control)
- **Maker Panel 16 HP** — 81.28 × 128.5 mm (large/complex)

Each template includes:
- ✓ Correct panel dimensions per specification
- ✓ Pre-positioned T-slot mounting holes
- ✓ Design area guides
- ✓ Edge.Cuts properly configured
- ✓ FR4 PCB material settings (1.6 mm)

## Available Templates

### makerpanel-4hp/
4 HP × 3U panel template (20.32 mm wide)
- **Use for**: Single potentiometer, minimal controls
- **Mounting holes**: 4 (two per edge)

### makerpanel-8hp/
8 HP × 3U panel template (40.64 mm wide) — **Most common size**
- **Use for**: 3-5 potentiometers, standard panels
- **Mounting holes**: 8 (four per edge)

### makerpanel-12hp/
12 HP × 3U panel template (60.96 mm wide)
- **Use for**: 6-10 controls, displays with controls
- **Mounting holes**: 10 (five per edge)

### makerpanel-16hp/
16 HP × 3U panel template (81.28 mm wide)
- **Use for**: Complex panels, many controls
- **Mounting holes**: 10 (five per edge)

## Installation

KiCad 9.0+ should automatically discover these templates when placed in the correct location.

**Manual registration (if needed):**

1. Copy all template directories (`makerpanel-*`) to:
   ```
   %AppData%\kicad\9.0\template\  (Windows)
   ~/.config/kicad/9.0/template/   (Linux)
   ~/Library/Application Support/kicad/9.0/template/ (macOS)
   ```

2. Restart KiCad

3. When creating a new project, templates should appear under "Maker Panel" category

## How to Use

### Method 1: Create from Template (Recommended)
1. Open KiCad
2. **Create New Project** → **Create from template**
3. Select **Maker Panel 8 HP** (or desired size)
4. Name your project
5. Start designing!

### Method 2: Open Template Directly
1. Go to `makerpanel-8hp/`
2. Open `template.kicad_pcb`
3. **File** → **Save As** → give your project name

## Specification Compliance

All templates follow the **Maker Panel Specification v1.0**:

- ✓ Width in HP units (1 HP = 5.08 mm)
- ✓ Height: 3U standard (128.5 mm)
- ✓ Maximum depth: 60 mm from front face
- ✓ T-slot compatible mounting (M5/M6 nuts)
- ✓ 2 mm minimum edge clearance
- ✓ 3 mm mounting holes on 25 mm intervals

See [Maker Panel Specification](../docs/specification.md) for complete details.

## Template Structure

```
templates/
├── makerpanel-4hp/
│   ├── meta/
│   │   ├── info.html          # Template description
│   │   └── meta.json          # Template metadata
│   ├── template.kicad_pcb     # PCB template file
│   └── icon.svg               # Template icon
├── makerpanel-8hp/
├── makerpanel-12hp/
├── makerpanel-16hp/
├── README.md                   # This file
├── KICAD_9_SETUP.md           # Installation guide
└── [other documentation]
```

Each template subdirectory contains:
- **meta.json**: Metadata for KiCad (name, description, dimensions, etc.)
- **template.kicad_pcb**: The actual KiCad PCB file ready to use

## Customization

### Creating Custom HP Sizes

You can create custom templates by:

1. Copying an existing template directory (e.g., `makerpanel-8hp/`)
2. Calculating your width: `HP_count × 5.08 mm`
3. Modifying `template.kicad_pcb` with new dimensions
4. Updating `meta.json` with new metadata
5. Following the coordinate calculations in [TECHNICAL_REFERENCE.md](../TECHNICAL_REFERENCE.md)

### Pro Tips

- Use 5.08 mm grid (1 HP) for component alignment
- Keep components within design area rectangle
- Maintain 2 mm clearance from Edge.Cuts
- Keep copper 3 mm away from mounting holes (M1-M10)

## Documentation

See the main templates directory for complete documentation:

- **README.md** — Full usage guide
- **QUICK_REFERENCE.md** — One-page reference (printable)
- **TECHNICAL_REFERENCE.md** — Detailed specifications & coordinates
- **INDEX.md** — Complete navigation guide

## Support

- Questions? Check [Maker Panel GitHub](https://github.com/Ranch-Hand-Robotics/makerpanel)
- Submit designs to the Gallery
- File issues or suggest improvements

## License

MIT License — use freely in personal and commercial projects.

---

**Maker Panel KiCad Templates v1.0**  
Designed for KiCad 8.0+  
Compliant with Maker Panel Specification v1.0
