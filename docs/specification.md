# Maker Panel Specification

## Overview

The Maker Panel specification defines a modular panel system for maker projects. Inspired by the Eurotrack synthesizer standard, Maker Panel adapts the concept for general-purpose control panels using **M-LOK style rails** for mounting.

## Design Philosophy

Maker Panel prioritizes:

- **Modularity**: Panels can be easily added, removed, or rearranged
- **Compatibility**: Standard dimensions ensure all compliant panels work together
- **Accessibility**: Open specification allows anyone to design panels
- **Flexibility**: M-LOK rails enable tool-free mounting and repositioning

## Visual Guide

### Panel Dimension System

```
WIDTH (HP Units)
├─ 1 HP = 5.08 mm (0.200")
│
├─ 4 HP  = 20.32 mm  ┌──────┐
├─ 6 HP  = 30.48 mm  ├──────────┐
├─ 8 HP  = 40.64 mm  ├──────────────┐
├─ 12 HP = 60.96 mm  ├──────────────────────┐
├─ 16 HP = 81.28 mm  ├──────────────────────────────┐
└─ 20+ HP configurable


HEIGHT (U Units)
│
├─ 1U = 44.45 mm (1.750")    ┌────────┐
│                            │        │
│                            │ Compact│
│                            │  Panel │
│
├─ 3U = 128.5 mm (5.059")    ┌──────────────┐
│                            │              │
│                            │  Standard    │
│                            │  Panel       │
│                            │              │
│                            │              │
│                            │              │
│                            │              │
│
└─ Custom heights available
```

### Panel Depth Profile

```
FRONT FACE (Bezel)
        ↓
        ┌─────────────────────────────────┐
        │                                 │  ↑
        │  [Control Elements]             │  │ 60mm MAX
        │  ◯ ◯ ◯  [Indicators]            │  │ Depth Limit
        │  ○ ○ ○  [Connectors]            │  ↓
        │                                 │
        └─────────────────────────────────┘
                        │
                    ────┴──── 10mm min clearance behind panel
                        │
            ┌───────────┴───────────┐
            │   PCB / Electronics   │
            │   (fits within 60mm)  │
            └───────────┬───────────┘
```

### M-LOK Rail Mounting System

```
              M3/M4 Screw (typical)
                     ↓
              ┌───────────────┐
            ┌─┤   T-Nut       ├─┐
            │ └───────────────┘ │
            │   Panel Mounting  │
            │        ↓          │
        ┌───┴───────────────────┴───┐
        │    PANEL (3mm max)        │
        │  ◯  ◯  [Elements]  ◯  ◯ │
        │                           │
        └───────────────────────────┘
```

### Panel on Rail Assembly

```
SIDE VIEW - PANEL MOUNTED ON RAIL SYSTEM

            ┌─────────────┐
            │ Top Rail    │
            └─────────────┘
                  │
    ┌─────┬──────┴──────┬─────┐
    │ T-Nut   T-Nut    T-Nut  │
    │     ∧        ∧        ∧ │
    │ ┌───┴────────┴────────┴───┐
    │ │      Panel (3U)         │
    │ │   ┌─────────────────┐   │
    │ │   │ ◯ ◯ ◯ ◯ ◯      │   │  ↑
    │ │   │ [CONTROLS]      │   │  │ 128.5mm
    │ │   │ ◯ ◯ ◯ ◯ ◯      │   │  │ (3U Height)
    │ │   │ ◯ ◯ ◯ ◯ ◯      │   │  ↓
    │ │   └─────────────────┘   │
    │ └───┬────────┬────────┬───┘
    │     ∨        ∨        ∨   │
    │ T-Nut   T-Nut    T-Nut  │
    └─────┴──────┬──────┴─────┘
                 │
            ┌─────────────┐
            │Bottom Rail  │
            └─────────────┘

    ← 5.08mm → (1 HP width unit)
```

## Mechanical Specifications

### Panel Dimensions

#### Width
Panels follow a **horizontal pitch (HP)** system:

- **1 HP** = 5.08 mm (0.200 inches)
- Common panel widths: 4 HP, 6 HP, 8 HP, 12 HP, 16 HP, 20 HP, 24 HP
- Panels can be any multiple of 1 HP

#### Height
Standard panel heights:

- **3U** = 128.5 mm (5.059 inches) - Standard height
- **1U** = 44.45 mm (1.750 inches) - Compact option
- Custom heights are allowed but should maintain M-LOK compatibility

#### Depth

- Maximum Standard panel depth: **60 mm** from front surface
- Recommended clearance behind panel: **10 mm minimum**

### M-LOK Style Rail System

Unlike traditional Eurotrack which uses grooved rails, Maker Panel uses **M-LOK style rails** for mounting. This style of rail can be can be laser cut or 3D printed, eliminating the need for custom aluminum extrusion dies.
    
#### Rail Specifications

- **Slot width**: 6.2 mm (0.244 inches)
- **Slot spacing**: Standard M-LOK pattern
- **Rail material**: Laser Cut Metal or Plastic or 3D Printed

#### Mounting Hardware

```
              M3/M4 Screw (typical)
                     ↓
              ┌───────────────┐
            ┌─┤   T-Nut       ├─┐
            │ └───────────────┘ │
            │   Panel Mounting  │
            │        ↓          │
        ┌───┴───────────────────┴───┐
        │    PANEL (3mm max)        │
        │  ◯  ◯  [Elements]  ◯   │
        │                           │
        └───────────────────────────┘
```

- **M-LOK compatible T-nuts** or custom retention clips
- Standard M3 or M4 screws for panel attachment
- Panels should include mounting slots or holes compatible with M-LOK spacing

### Panel Material

Recommended materials:

- **Aluminum**: 2mm-3mm thickness (most common)
- **FR4/PCB**: 1.6mm thickness (for electronic panels)
- **Acrylic/Polycarbonate**: 3mm thickness (for transparent panels)
- **3D Printed**: PLA, PETG, or ABS (ensure adequate rigidity)

## Electrical Specifications

### Power Distribution

Maker Panel does not mandate a specific power distribution system, but common options include:

- **Bus strips** behind panels (e.g., +12V, GND, -12V for analog circuits)
- **USB-C PD** distribution
- **Individual power connections** per panel

### Connectors

Recommended connector types:

- **Qwiic/StemmaQT**: For I²C low-current signals
- **Screw terminals**: For power connections
- **USB-C**: For highspeed data and power connections

## Design Guidelines

### Clearances

- **Minimum edge clearance**: 2 mm from panel edges
- **Mounting hole clearance**: 3 mm diameter minimum for M3 screws
- **Component clearance**: Ensure no component extends beyond maximum depth

### Labeling

- Use clear, legible labeling for controls and connections
- Recommended minimum font size: 8pt for labels
- Consider silkscreen, engraving, or UV printed labels

### Aesthetics

While aesthetics are subjective, consider:

- Consistent visual design across your panel set
- Alignment of controls and indicators
- Professional finish (smooth edges, no sharp corners)

## File Format Standards

When sharing panel designs, include:

1. **Mechanical drawings**: KiCAD, DXF or SVG format
2. **3D models**: OpenSCAD, 3MF, STEP, or STL format
3. **Electrical Schematics**: KiCad format
4. **Bill of Materials (BOM)**: Markdown tables
5. **Assembly instructions**: Markdown

## Compliance Checklist

To be Maker Panel-compliant, your panel should:

- [ ] Use width in HP units (1 HP = 5.08 mm)
- [ ] Include M-LOK compatible mounting points
- [ ] Not exceed 60 mm depth from front face
- [ ] Have 2 mm minimum edge clearance
- [ ] Include clear labeling
- [ ] Provide mechanical drawings in open format
- [ ] Document any electrical specifications

## Variations and Extensions

The Maker Panel specification is intentionally flexible. Variations are encouraged as long as they maintain basic compatibility:

- **Custom heights**: For specific applications
- **Extended depth**: For complex assemblies (document clearly)
- **Integrated systems**: Multi-panel assemblies
- **Powered rails**: Custom power distribution systems

## Reference Designs

See the [Gallery](gallery.md) for example panels that follow this specification.

## Questions and Clarifications

For questions about the specification or to propose extensions:

- Open an issue on the [GitHub repository](https://github.com/Ranch-Hand-Robotics/makerpanel)
- Contribute to the discussion in existing issues
- Submit pull requests for specification improvements

---

**Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: Ranch Hand Robotics and the Maker Panel community