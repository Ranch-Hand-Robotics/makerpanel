# Makerpanel Specification

## Overview

The Makerpanel specification defines a modular panel system for maker projects. Inspired by the Eurotrack synthesizer standard, Makerpanel adapts the concept for general-purpose control panels using **M-LOK style rails** for mounting.

## Design Philosophy

Makerpanel prioritizes:

- **Modularity**: Panels can be easily added, removed, or rearranged
- **Compatibility**: Standard dimensions ensure all compliant panels work together
- **Accessibility**: Open specification allows anyone to design panels
- **Flexibility**: M-LOK rails enable tool-free mounting and repositioning

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
- Maximum panel depth: **60 mm** from front surface
- Recommended clearance behind panel: **80 mm minimum**

### M-LOK Rail System

Unlike traditional Eurotrack which uses grooved rails, Makerpanel uses **M-LOK style rails** for mounting:

#### Rail Specifications
- **Slot width**: 6.2 mm (0.244 inches)
- **Slot spacing**: Standard M-LOK pattern (centered every 13 mm)
- **Rail material**: Aluminum extrusion (recommended) or compatible material
- **Surface**: Anodized or powder-coated finish recommended

#### Mounting Hardware
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

Makerpanel does not mandate a specific power distribution system, but common options include:

- **Bus strips** behind panels (e.g., +12V, GND, -12V for analog circuits)
- **USB power** distribution
- **Individual power connections** per panel
- **PoE (Power over Ethernet)** for network-enabled panels

### Connectors

Recommended connector types:
- **Pin headers**: For low-current signals
- **Screw terminals**: For power connections
- **JST connectors**: For modular cable connections
- **RJ45**: For network and data connections

## Design Guidelines

### Clearances

- **Minimum edge clearance**: 2 mm from panel edges
- **Mounting hole clearance**: 3 mm diameter minimum for M3 screws
- **Component clearance**: Ensure no component extends beyond maximum depth

### Labeling

- Use clear, legible labeling for controls and connections
- Recommended minimum font size: 8pt for labels
- Consider silkscreen, engraving, or printed labels

### Aesthetics

While aesthetics are subjective, consider:
- Consistent visual design across your panel set
- Alignment of controls and indicators
- Professional finish (smooth edges, no sharp corners)

## File Format Standards

When sharing panel designs, include:

1. **Mechanical drawings**: DXF or SVG format
2. **3D models**: STEP or STL format
3. **Schematics**: PDF or KiCad/Eagle format (if electronic)
4. **Bill of Materials (BOM)**: CSV or spreadsheet
5. **Assembly instructions**: Markdown or PDF

## Compliance Checklist

To be Makerpanel-compliant, your panel should:

- [ ] Use width in HP units (1 HP = 5.08 mm)
- [ ] Include M-LOK compatible mounting points
- [ ] Not exceed 60 mm depth from front face
- [ ] Have 2 mm minimum edge clearance
- [ ] Include clear labeling
- [ ] Provide mechanical drawings in open format
- [ ] Document any electrical specifications

## Variations and Extensions

The Makerpanel specification is intentionally flexible. Variations are encouraged as long as they maintain basic compatibility:

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
**Maintained by**: Ranch Hand Robotics and the Makerpanel community
