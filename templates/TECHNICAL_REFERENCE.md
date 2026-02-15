# Maker Panel KiCad Templates - Technical Reference

## Quick Start

### Choosing Your Template

| Your Panel Needs | Recommended | Size |
|------------------|------------|------|
| 1-2 small controls (single pot, button) | 4 HP | 20.32 × 128.5 mm |
| 3-5 controls (potentiometers, knobs) | 8 HP | 40.64 × 128.5 mm |
| 6-10 controls + display | 12 HP | 60.96 × 128.5 mm |
| Complex panel (many controls) | 16 HP | 81.28 × 128.5 mm |

### Opening a Template (KiCad 8.0+)

```
File → Open → templates/makerpanel-8hp-template.kicad_pcb
```

Then **File → Save As** to create your project.

## Dimension Reference (All measurements in mm)

### HP Unit System

```
1 HP  = 5.08 mm (standard unit of width)

Common sizes:
4 HP  = 20.32 mm
6 HP  = 30.48 mm    (use 4 HP + 2 HP spacing)
8 HP  = 40.64 mm    ← Available template
10 HP = 50.8 mm
12 HP = 60.96 mm    ← Available template
16 HP = 81.28 mm    ← Available template
20 HP = 101.6 mm
24 HP = 121.92 mm
```

### Height (U Unit System)

```
1U (Unit)   = 44.45 mm
3U Panel    = 128.5 mm      (5.059 inches) ← Standard height
3U Spacing  = 133.35 mm     (5.250 inches, rail centers)
```

### Depth Constraint

```
Maximum depth: 60 mm from front bezel face to rear
Clearance diagram:

    Front Face
         ↓
    ┌────────────┐
    │ [Controls] │  ← Depth limit: 60 mm
    │   | | |    │
    └────────────┘
         ↑
         ├─ At least 10 mm clearance to back
         ├─ PCB, wiring, connector space here
         └─ Total: front to connector back < 60 mm
```

## Mounting Hole Specifications

### Standard Panel Hole Pattern

All templates have mounting holes positioned for T-slot rail compatibility:

- **Size**: 3 mm diameter (M3 screw clearance)
- **Position**: Top and bottom edges of panel
- **Spacing**: 25 mm intervals (compatible with T-slot systems)
- **Material**: Threaded using M5/M6 T-nuts in rails

### Hole Placement Examples

#### 4 HP Panel (20.32 mm wide)
```
       Top View
    ┌─────────────┐
    │ M1   M2     │  Y = -58.42 mm
    │             │
    │   Design    │
    │    Area     │  (Total height: 128.5 mm)
    │             │
    │ M3   M4     │  Y = +58.42 mm
    └─────────────┘
    X: -7.62, +7.62 mm (left/right edges)
```

#### 8 HP Panel (40.64 mm wide)
```
       Top View
    ┌──────────────────┐
    │ M1  M5 M6  M2    │  Y = -58.42 mm
    │                  │
    │    Design Area   │
    │    (128.5 mm H)  │
    │                  │
    │ M3  M7 M8  M4    │  Y = +58.42 mm
    └──────────────────┘
    X: -15.24, -5.08, +5.08, +15.24 mm
```

#### 12 HP Panel (60.96 mm wide)
```
       Top View
    ┌───────────────────────────┐
    │ M1  M5  M9  M6  M2        │  Y = -58.42 mm
    │                           │
    │       Design Area         │
    │      (128.5 mm H)         │
    │                           │
    │ M3  M7  M10 M8  M4        │  Y = +58.42 mm
    └───────────────────────────┘
    X: -25.4, -12.7, 0, +12.7, +25.4 mm
```

### Creating Custom HP Sizes

**Formula**: X positions = ±(HP/2 × 5.08) at 25mm intervals from center

Example for 6 HP (30.48 mm):
- Total width = 6 × 5.08 = 30.48 mm
- X positions: ±15.24 mm (edges), ±5.08 mm (center pair)

In KiCad:
1. Modify Edge.Cuts layer X coordinates to ±15.24
2. Place M1 and M2 at X = ±15.24, Y = -58.42
3. Place M3 and M4 at X = ±15.24, Y = +58.42
4. (Optional) Add center holes: ±5.08, ±58.42

## KiCad Coordinate System

**KiCad uses standard Cartesian coordinates:**

```
            ← negative X | positive X →
                        ↓
        ┌──────────────────────────────┐  ↑ positive Y
        │          Panel               │  │
        │    (Origin at center)        │  │
        │        (0, 0)                │  │
        │                              │  ↓ negative Y
        └──────────────────────────────┘
```

- **Origin (0, 0)**: Center of panel by design
- **X-axis**: Runs left (negative) to right (positive)
- **Y-axis**: Runs bottom (negative) to top (positive)
- **Unit**: Millimeters (mm)

### Using Coordinates in Templates

All mounting holes follow this convention. For example:

```
Hole M1 position: (-15.24, -58.42)
= 15.24 mm to the LEFT
  58.42 mm DOWN from center
```

## Component Placement Guidelines

### Safe Design Area

Keep components within these bounds:

```
Panel width:  ±(width/2 - 2) mm
Panel height: ±64.25 mm (128.5 / 2 - 0 mm → full usable height)
              (Note: full height, edges have 2 mm clearance)

4 HP:   X: -8.16 to +8.16 mm,    Y: -64.25 to +64.25 mm
8 HP:   X: -18.32 to +18.32 mm,  Y: -64.25 to +64.25 mm
12 HP:  X: -28.48 to +28.48 mm,  Y: -64.25 to +64.25 mm
16 HP:  X: -38.64 to +38.64 mm,  Y: -64.25 to +64.25 mm
```

### Component Clearances

- **Edge clearance**: Keep traces/pads ≥2 mm from Edge.Cuts layer
- **Mounting hole clearance**: Keep copper ≥3 mm away from M1-M10 holes
- **Via clearance**: Keep vias ≥2 mm from edges, ≥1 mm from holes
- **Silkscreen**: Drawn at 0.254 mm line width in F.SilkS layer

## PCB Manufacturing

### Standard Fab House Settings

When ordering from JLCPCB, PCBWay, Oshpark, etc. use:

- **Thickness**: 1.6 mm FR4
- **Copper weight**: 1 oz (standard)
- **Solder mask**: Green (or custom color)
- **Silkscreen**: White
- **Surface finish**: HASL or ENIG
- **Minimum trace width**: 0.15 mm
- **Minimum trace spacing**: 0.15 mm
- **Via size**: 0.3 mm drill

### Gerber Files to Generate

In KiCad **File → Fabrication Outputs → Gerbers**:

1. ✓ F.Cu (Front copper)
2. ✓ B.Cu (Back copper)
3. ✓ F.SilkS (Front silkscreen)
4. ✓ B.SilkS (Back silkscreen)
5. ✓ F.Mask (Front solder mask)
6. ✓ B.Mask (Back solder mask)
7. ✓ Edge.Cuts (Panel outline) ← **CRITICAL**

Also generate **Drill files** (in mm, not inch)

## Design Checklist Before Ordering

- [ ] All components fit within 60 mm depth
- [ ] Mounting holes (M1-M10) are unobstructed
- [ ] Edge clearance: No copper within 2 mm of edges
- [ ] Silkscreen text is legible (min 1.27 mm height)
- [ ] All nets are connected (no floating copper)
- [ ] DRC (Design Rule Check) passes: Tools → Design Rule Checker
- [ ] Edge.Cuts layer forms a closed loop (can be verified in 3D view)
- [ ] Panel dimensions confirmed in F.SilkS layer notes
- [ ] Gerbers include all required layers (especially Edge.Cuts)
- [ ] Bill of Materials (BOM) is complete and accurate

## Common Mistakes to Avoid

| Mistake | Impact | Prevention |
|---------|--------|-----------|
| Copper near mounting holes | Manufacturing defect | Use design area rectangle as guide |
| Missing Edge.Cuts in Gerber export | Can't fabricate correctly | Enable Edge.Cuts in plot settings |
| Traces too thin (< 0.15 mm) | Manufacturing failure | Use 0.25 mm minimum |
| Silkscreen over pads | Label obscured, pins hard to ID | Keep silkscreen away from pads |
| Panel too deep (> 60 mm) | Won't fit on rails | Check all component heights during design |
| Mounting holes blocked by traces | Assembly impossible | Check DRC doesn't allow this |
| Wrong coordinates (inch vs mm) | Panel complete wrong size | Verify KiCad is set to mm |

## Glossary

| Term | Definition |
|------|-----------|
| HP | Horizontal Pitch, unit of width (5.08 mm) |
| 1U | Standard height unit (44.45 mm) |
| 3U | Standard panel height (3 × 1U = 128.5 mm) |
| T-slot | Rail system with channels for mounting nuts |
| T-nut | M5/M6 nut that slides into T-slot rails |
| Edge.Cuts | KiCad layer defining the final PCB outline |
| DRC | Design Rule Check - validates PCB layout |
| Gerber | Industry-standard PCB fabrication file format |
| Silkscreen | Non-conductive printed layer for labeling |
| Via | Copper hole connecting front and back layers |
| PTH | Plated-through hole (via or component lead hole) |
| FR4 | Glass fiber composite PCB material |

## Example: Creating a 6 HP Template

If you need a 6 HP (30.48 mm) template not provided:

1. **Open**: makerpanel-4hp-template.kicad_pcb
2. **Edit Edge.Cuts**: Modify rectangle from:
   ```
   (start -10.16 -64.25) to (start -15.24 -64.25)
   (end 10.16 64.25) to (end 15.24 64.25)
   ```
3. **Move holes**: (from 4 HP spacing to 6 HP)
   ```
   Pad M1: (-7.62, -58.42) → (-15.24, -58.42)
   Pad M2: (7.62, -58.42) → (15.24, -58.42)
   Pad M3: (-7.62, 58.42) → (-15.24, 58.42)
   Pad M4: (7.62, 58.42) → (15.24, 58.42)
   ```
4. **Add center pair** (optional):
   ```
   New Pad M5: (-5.08, -58.42)
   New Pad M6: (5.08, -58.42)
   New Pad M7: (-5.08, 58.42)
   New Pad M8: (5.08, 58.42)
   ```
5. **Update title block**: "6 HP × 3U (30.48 mm × 128.5 mm)"

## Resources & Links

- **Maker Panel Specification**: ../docs/specification.md
- **KiCad Documentation**: https://docs.kicad.org/en/8.0/
- **KiCad Forum**: https://forum.kicad.info/
- **T-slot Rail Suppliers**:
  - OpenBeam: http://openbeamusa.com/
  - MiSUMi: https://us.misumi-ec.com/
  - 80/20: https://www.80-20.net/
- **PCB Fab Houses**:
  - JLCPCB: https://jlcpcb.com/
  - PCBWay: https://www.pcbway.com/
  - Oshpark: https://oshpark.com/

---

**Document Version**: 1.0  
**Last Updated**: February 2025  
**For**: Maker Panel Specification v1.0  
**Compatible with**: KiCad 8.0.0 and later
