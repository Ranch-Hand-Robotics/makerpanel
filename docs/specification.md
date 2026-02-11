<!-- Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

# Maker Panel Specification

## Overview

The Maker Panel specification defines a modular panel system for maker projects. Inspired by the Eurotrack synthesizer standard, Maker Panel adapts the concept for general-purpose control panels using **standard T-slot rails** with M5/M6 twist nuts for mounting.

## Design Philosophy

Maker Panel prioritizes:

- **Modularity**: Panels can be easily added, removed, or rearranged
- **Compatibility**: Standard dimensions ensure all compliant panels work together
- **Accessibility**: Open specification allows anyone to design panels
- **Flexibility**: T-slot rails enable tool-free mounting and repositioning with standard M5/M6 nuts

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
│  (Unit spacing)             │        │
│                            │ Compact│
│                            │  Panel │
│
├─ 3U Panel  = 128.5 mm      ┌──────────────┐
│  (5.059" panel height)     │              │
│                            │  Standard    │
├─ 3U Space = 133.35 mm      │  Panel       │
│  (5.250" rail spacing)     │              │
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
        │  ◯ ◯ ◯  [Indicators]         │  │ Depth Limit
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

### T-Slot Rail Mounting System

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
        │  ◯    [Elements]     ◯  │
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
    ┌─────┬───────┴──────┬─────┐
    │ T-Nut   T-Nut    T-Nut   │
    │     ∧        ∧        ∧  │
    │ ┌───┴────────┴────────┴───┐
    │ │      Panel (3U)         │
    │ │   ┌─────────────────┐   │
    │ │   │ ◯ ◯ ◯ ◯ ◯  │   │  ↑
    │ │   │ [CONTROLS]      │   │  │ 128.5mm
    │ │   │ ◯ ◯ ◯ ◯ ◯  │   │  │ (3U Panel)
    │ │   │ ◯ ◯ ◯ ◯ ◯  │   │  ↓
    │ │   └─────────────────┘   │
    │ └───┬────────┬────────┬───┘
    │     ∨        ∨        ∨  │
    │ T-Nut   T-Nut    T-Nut   │
    └─────┴──────┬───────┴─────┘
                 │
            ┌─────────────┐
            │Bottom Rail  │
            └─────────────┘
    
    ↑                           ↑
    └─── 133.35mm (3U Spacing) ─┘
         (Rail mounting centers)

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

- **1U** = 44.45 mm (1.750 inches) - Unit spacing
- **3U Panel** = 128.5 mm (5.059 inches) - Standard panel height (allows 2.5mm clearance per rail)
- **3U Spacing** = 133.35 mm (5.250 inches) - Rail mounting centers (3 × 1U)
- Custom heights are allowed but should maintain T-slot compatibility

#### Depth

- Standard panel depth: **60 mm** from front surface
- Recommended clearance behind panel: **10 mm minimum**

### Maker Panel Rack System

Unlike traditional Eurotrack which uses grooved rails, Maker Panel uses **standard T-slot rails** with M5/M6 twist nuts for mounting. This approach enables tool-free, repositionable mounting while using widely available, off-the-shelf components.
    
#### Rack Specifications

Rails are designed to work in both orientations (horizontal cross beams or vertical side rails):

- **Slot height**: 6.2 mm (0.244 inches) - Accepts 3mm panels with clearance
- **Slot width**: 19.125 mm (0.753 inches) - Half of 1U minus support width [(44.45 - 6.2) / 2]
- **Support width**: 6.2 mm (0.244 inches) - Structural support between slots
- **Support spacing**: 44.45 mm (1.750 inches) - 1U intervals, creates two slots per U
- **Rail material**: Laser Cut Metal or Plastic or 3D Printed

*Design rationale: Slots spaced at 1U intervals (44.45mm) work for both vertical structural support and horizontal panel mounting. For horizontal rails, panels mount across multiple slots. For vertical rails, the 1U spacing provides consistent mounting points.*

#### Rail Configurations

A rail consists of alternating slots and supports, with supports spaced every 1U (44.45mm). This creates **two slots per 1U interval**. Optional mounting holes can be added on either side for structural assembly.

The **same rail design** works for both cross beams (horizontal) and side beams (vertical):
- **Cross beams**: Panels mount horizontally across multiple slots, aligning with HP widths
- **Side beams**: Vertical mounting uses 1U-spaced slots for consistent panel positioning

Rails are used for sides and cross beams, while panels are mounted between cross beams.

*Rail as cross beam (horizontal orientation)*

```
              Rail 
             Height                    < Slot width: 19.125mm >
            <  |   >                   
    ↑       ┌────────────────────────────────────────────────────────────────────┐
            │      ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │      ↑
Rail Height │  ◯  │               │  │               │  │               │  ◯   │  Slot Height
            │      └───────────────┘  └───────────────┘  └───────────────┘       │  6.2mm
    ↓       └────────────────────────────────────────────────────────────────────┘      ↓
                                   <  >
                                  Support
                               Width: 6.2mm
                   < --------- 44.45mm (1U) --------->
                   (Support + Slot + Support + Slot)
```

*Rail as Side Beam (vertical orientation)*

```
  Rail 
 Height              Support: 6.2mm
<  |   >                  ↓
┌──────┐               ← ─ ─ →
│ ┌──┐ │ ←────┐          ↑
│ │  │ │      │      19.125mm
│ │  │ │     Slot     (Slot
│ │  │ │     Width     Width)
│ │  │ │      │          ↓
│ └──┘ │ ←────┘       ← ─ ─ →
│ ═══  │ ← Support (6.2mm)
│ ┌──┐ │              ↑ 44.45mm ↓
│ │  │ │              ↓  (1U)   ↑
│ │  │ │             ← ─ ─ →
│ │  │ │
│ │  │ │
│ └──┘ │
│ ═══  │ ← Support (6.2mm)
│ ┌──┐ │              
│ │  │ │
│ │  │ │
│ │  │ │
│ │  │ │
│ └──┘ │
│      │
└──────┘
```
*Pattern repeats every 1U (44.45mm) with two slots per U interval*



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

- **T-slot compatible nuts** (M5/M6 twist nuts or drop-in style)
- Standard M3 or M4 screws for panel attachment
- Panels should include mounting slots or holes compatible with T-slot spacing (25 mm centers)

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

- [x] Use width in HP units (1 HP = 5.08 mm)
- [x] Include T-slot compatible mounting points (M5/M6)
- [x] Not exceed 60 mm depth from front face
- [x] Have 2 mm minimum edge clearance
- [x] Include clear labeling
- [x] Provide mechanical drawings in open format
- [x] Document any electrical specifications

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
**Last Updated**: February 2026  
**Maintained by**: Ranch Hand Robotics and the Maker Panel community