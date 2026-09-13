---
hide:
  - navigation
  - toc
title: " "
---
<!-- Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved. Licensed under MIT License. -->

# Maker Panel Specification

The Maker Panel specification defines a modular panel system for maker projects.
Inspired by the Eurorack synthesizer standard, MakerPanel adapts the concept for
general-purpose control panels. Mount panels on compatible **T-tracks**, or make
your own rails using **MakerRail slots**. These are different rail constructions,
not two names for the same profile.

## Design Philosophy

Maker Panel prioritizes:

- **Modularity**: Panels can be easily added, removed, or rearranged
- **Compatibility**: Standard dimensions ensure all compliant panels work together
- **Accessibility**: Open specification allows anyone to design panels
- **Flexibility**: Choose compatible off-the-shelf T-tracks or MakerRails made by
        3D printing or laser cutting suitable plastic or metal sheet

## Visual Guide

### Panel Dimension System

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 370" role="img" aria-labelledby="hp-title hp-desc">
        <title id="hp-title">Panel widths in horizontal pitch units</title>
        <desc id="hp-desc">One HP is 5.08 mm. Bars compare 4, 6, 8, 12, and 16 HP widths: 20.32, 30.48, 40.64, 60.96, and 81.28 mm respectively.</desc>
        <text x="24" y="34" class="diagram-heading">01 / WIDTH IN HP</text>
        <text x="24" y="68" class="diagram-value">1 HP = 5.08 mm / 0.200 inches</text>
        <path class="diagram-guide" d="M105 95V329"/>
        <g class="diagram-panel">
                <rect x="105" y="101" width="55" height="30" rx="3"/>
                <rect x="105" y="146" width="82.5" height="30" rx="3"/>
                <rect x="105" y="191" width="110" height="30" rx="3"/>
                <rect x="105" y="236" width="165" height="30" rx="3"/>
                <rect x="105" y="281" width="220" height="30" rx="3"/>
        </g>
        <g class="diagram-value">
                <text x="24" y="123">4 HP</text><text x="24" y="168">6 HP</text>
                <text x="24" y="213">8 HP</text><text x="24" y="258">12 HP</text>
                <text x="24" y="303">16 HP</text>
        </g>
        <text x="174" y="123">20.32 mm</text><text x="202" y="168">30.48 mm</text>
        <text x="229" y="213">40.64 mm</text><text x="284" y="258">60.96 mm</text>
        <text x="339" y="303">81.28 mm</text>
        <text x="24" y="348" class="diagram-muted">20 HP, 24 HP and beyond →</text>
</svg>
<figcaption><strong>Build in multiples.</strong> Choose any whole number of HP; each step adds 5.08 mm of width.</figcaption>
</figure>

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 390" role="img" aria-labelledby="u-title u-desc">
        <title id="u-title">Compact and standard panel heights</title>
        <desc id="u-desc">One U is 44.45 mm unit spacing. A standard 3U panel is 128.5 mm tall within a nominal 133.35 mm unit space. With 11 mm rails and holes inset 5.5 mm from each edge, mounting centers are 117.5 mm apart.</desc>
        <text x="24" y="34" class="diagram-heading">02 / HEIGHT IN U</text>
        <rect class="diagram-panel" x="46" y="210" width="100" height="89" rx="4"/>
        <rect class="diagram-panel" x="244" y="85" width="130" height="214" rx="4"/>
        <g class="diagram-detail">
                <path d="M58 221h12m-6 -6v12M122 288h12m-6 -6v12"/>
                <path d="M256 97h12m-6 -6v12M350 287h12m-6 -6v12"/>
        </g>
        <text x="96" y="265" text-anchor="middle" class="diagram-on-panel">Compact</text>
        <text x="309" y="198" text-anchor="middle" class="diagram-on-panel">3U panel</text>
        <path class="diagram-dimension" d="M163 210h16m-8 0v89m-8 0h16M391 85h16m-8 0v214m-8 0h16"/>
        <text x="24" y="337" class="diagram-value">1U = 44.45 mm</text>
        <text x="244" y="337" class="diagram-value">128.5 mm panel</text>
        <text x="24" y="363" class="diagram-muted">Unit spacing</text>
        <text x="244" y="363" class="diagram-muted">133.35 mm unit space</text>
</svg>
<figcaption><strong>Panel height ≠ unit spacing.</strong> 3U uses a 128.5 mm panel within a nominal 133.35 mm unit space. With 11 mm rails, mounting centers are 117.5 mm apart. Schematic; custom heights are allowed.</figcaption>
</figure>

### Panel Depth Profile

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 350" role="img" aria-labelledby="depth-title depth-desc">
        <title id="depth-title">Panel depth measured from the front surface</title>
        <desc id="depth-desc">Side section: controls sit in front of the panel, electronics behind it. The rear depth envelope ends 60 mm from the front surface. Allow at least 10 mm clearance behind the panel.</desc>
        <text x="24" y="34" class="diagram-heading">03 / SIDE SECTION</text>
        <text x="24" y="76">Front face</text>
        <path d="M115 71h30v40"/>
        <path class="diagram-guide" d="M145 90V305M424 90V305"/>
        <rect class="diagram-panel" x="145" y="112" width="15" height="163"/>
        <rect class="diagram-rail" x="99" y="147" width="30" height="47" rx="4"/>
        <path d="M129 165h16m-16 10h16"/>
        <rect class="diagram-rail" x="222" y="126" width="12" height="135"/>
        <rect class="diagram-rail" x="234" y="156" width="105" height="65" rx="3"/>
        <path d="M160 135h62m-62 112h62"/>
        <text x="249" y="194">Electronics</text>
        <text x="24" y="233" class="diagram-muted">Controls</text>
        <path class="diagram-dimension" d="M160 281v16m0 -8h62m0 -8v16M145 308v16m0 -8h279m0 -8v16"/>
        <text x="242" y="295">10 mm min clearance</text>
        <text x="284" y="343" text-anchor="middle" class="diagram-value">60 mm maximum from front face</text>
</svg>
<figcaption><strong>Leave room behind the face.</strong> Keep electronics within the 60 mm depth envelope and allow at least 10 mm rear clearance. Side-section schematic, not to scale.</figcaption>
</figure>

### T-Slot Rail Mounting System

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 370" role="img" aria-labelledby="track-title track-desc">
        <title id="track-title">Conventional T-track mounting cross-section</title>
        <desc id="track-desc">A screw passes through the panel into a matching threaded T-nut retained beneath the lips of a continuous T-track channel. This is not the flat MakerRail through-slot profile.</desc>
        <text x="24" y="34" class="diagram-heading">04 / CONTINUOUS T-TRACK</text>
        <rect class="diagram-rail" x="100" y="89" width="70" height="22" rx="5"/>
        <rect class="diagram-panel" x="43" y="127" width="181" height="19"/>
        <path class="diagram-rail" d="M43 178H115V200H70V268H200V200H155V178H224V292H43Z"/>
        <rect class="diagram-rail" x="88" y="211" width="95" height="26" rx="3"/>
        <rect class="diagram-rail" x="128" y="111" width="14" height="126"/>
        <path d="M130 156l10 -5m-10 16l10 -5m-10 16l10 -5m-10 16l10 -5m-10 16l10 -5"/>
        <path class="diagram-guide" d="M172 100H254M225 136H254M184 224H254M225 281H254"/>
        <text x="265" y="106">Screw</text>
        <text x="265" y="142">Panel</text>
        <text x="265" y="230">Matching T-nut</text>
        <text x="265" y="287">Channel / rail</text>
        <text x="24" y="339" class="diagram-muted">Nut retained beneath the channel lips</text>
</svg>
<figcaption><strong>A captured nut, a continuous channel.</strong> Select a screw that matches the nut thread. Cross-section schematic; commercial track profiles vary.</figcaption>
</figure>

### Panel on Rail Assembly

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 480" role="img" aria-labelledby="assembly-title assembly-desc">
        <title id="assembly-title">Panel holes aligned with mounting rail centerlines</title>
        <desc id="assembly-desc">Front view of a 128.5 mm panel overlapping two 11 mm mounting rails. All four hole centers are inset 5.5 mm from the top or bottom and nearest side edge. Horizontal rail centerlines pass through the hole centers, 117.5 mm apart. Width is chosen in multiples of 5.08 mm.</desc>
        <text x="24" y="34" class="diagram-heading">05 / FRONT ASSEMBLY</text>
        <text x="24" y="65">Hole inset = rail width / 2 = 5.5 mm</text>
        <!-- Geometry scale: 2 SVG units per mm; rail width 22, inset 11. -->
        <rect id="assembly-top-rail" class="diagram-rail" x="47" y="100" width="255" height="22" rx="3"/>
        <rect id="assembly-bottom-rail" class="diagram-rail" x="47" y="335" width="255" height="22" rx="3"/>
        <rect id="assembly-panel" class="diagram-panel" x="74" y="100" width="201" height="257" rx="4"/>
        <path class="diagram-detail" stroke-dasharray="3 5" d="M74 122H275M74 335H275"/>
        <g class="diagram-detail" stroke-dasharray="6 4">
                <line id="assembly-top-center" x1="35" y1="111" x2="447" y2="111"/>
                <line id="assembly-bottom-center" x1="35" y1="346" x2="447" y2="346"/>
                <line id="assembly-left-center" x1="85" y1="82" x2="85" y2="376"/>
                <line id="assembly-right-center" x1="264" y1="82" x2="264" y2="376"/>
        </g>
        <g id="assembly-holes" class="diagram-void">
                <circle cx="85" cy="111" r="4"/><circle cx="264" cy="111" r="4"/>
                <circle cx="85" cy="346" r="4"/><circle cx="264" cy="346" r="4"/>
        </g>
        <g class="diagram-detail">
                <rect x="101" y="153" width="146" height="44" rx="3"/>
                <circle cx="121" cy="230" r="13"/><circle cx="175" cy="230" r="13"/>
                <circle cx="228" cy="230" r="13"/>
        </g>
        <text x="174" y="281" text-anchor="middle" class="diagram-on-panel">3U panel</text>
        <path class="diagram-guide" d="M275 100H329M275 357H329"/>
        <path class="diagram-dimension" d="M313 100h16m-8 0v257m-8 0h16M431 111h16m-8 0v235m-8 0h16"/>
        <text transform="translate(346 229) rotate(-90)" text-anchor="middle" class="diagram-value">128.5 mm panel</text>
        <text transform="translate(422 229) rotate(-90)" text-anchor="middle">117.5 mm centers</text>
        <path class="diagram-dimension" d="M74 385v16m0 -8h201m0 -8v16"/>
        <text x="174" y="425" text-anchor="middle">Width = HP × 5.08 mm</text>
        <text x="24" y="459" class="diagram-muted">Dashed lines show centers and hidden rails.</text>
</svg>
<figcaption><strong>Holes on the rail centerlines.</strong> The rails sit behind the panel, not beyond it. Each hole center is inset half the rail width (5.5 mm) from both adjacent panel edges: top or bottom and left or right. Center spacing is panel height minus rail width: 128.5 − 11 = 117.5 mm. Schematic; rail-slot details are omitted for clarity.</figcaption>
</figure>

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
- **3U Panel** = 128.5 mm (5.059 inches) - Standard panel height
- **3U Spacing** = 133.35 mm (5.250 inches) - Nominal unit space (3 × 1U), not rail mounting-center spacing
- **Mounting hole inset** = half the rail width from each adjacent panel edge (top, bottom and sides): 5.5 mm for an 11 mm rail
- **Rail mounting-center spacing** = panel height minus rail width: 117.5 mm for a 128.5 mm panel on 11 mm rails
- Custom heights are allowed but should maintain T-slot compatibility

#### Depth

- Standard panel depth: **60 mm** from front surface
- Recommended clearance behind panel: **10 mm minimum**

#### Measuring Tool

Use the [MakerPanel / MakerRail measuring tool][measure-tool] to check panel
and rail dimensions before fabrication or assembly. This printable OpenSCAD
example provides panel and rail gauges; set `part` to `"makerpanel"` or `"rail"`
and adjust `verticalUnits` and `horizontalPitch` for the size you need.

[measure-tool]: https://github.com/Ranch-Hand-Robotics/makerpanel/blob/main/examples/measure/measure.scad

### Maker Panel Rack System

#### T-tracks and MakerRail slots

**T-track** describes a conventional rail with a continuous channel, typically
an aluminum extrusion. Matching T-nuts are retained by the channel and can slide
along its length. Select a track profile and hardware that fit the panel mounting
points; commercial T-tracks are not all interchangeable.

**MakerRail** uses discrete through-slots separated by structural ribs. The
reference rail is a flat slotted profile, not an extruded T-channel. Compatible
twist nuts engage the slot edges; the ribs interrupt travel between slots.
Allow clearance behind the rail for the nut and screw, including room to insert
and turn the nut.

This slot-based construction supports three fabrication routes:

- **3D printing**: Print the rail profile as a solid part. Choose material,
        orientation, and wall construction appropriate to the load.
- **Laser-cut plastic**: Cut the 2D profile from laser-safe plastic sheet suited
        to the application and cutting equipment.
- **Laser-cut metal**: Cut the same 2D profile from suitable metal sheet with
        equipment or a fabrication service rated for that material and thickness.

The reference library provides `maker_rail()` for 3D geometry and
`maker_rail_2d()` for 2D profiles. `makerpanel/rails_laser.scad` is the SVG/DXF
export entry point. See the [OpenSCAD workflow](openscad.md) to get started.

**Hardware compatibility is not profile equivalence.** Check the actual nut
body, screw thread, slot opening, rail thickness, and rear clearance. Test a
sample joint before fabricating a complete frame; changing the material or
manufacturing process does not guarantee the same strength or fit.

#### MakerRail Rack Specifications

Rails are designed to work in both orientations (horizontal cross beams or vertical side rails):

- **Slot height**: 6.2 mm (0.244 inches) - Accepts 3mm panels with clearance
- **Slot width**: 19.125 mm (0.753 inches) - Half of 1U minus support width [(44.45 - 6.2) / 2]
- **Support width**: 6.2 mm (0.244 inches) - Structural support between slots
- **Support spacing**: 44.45 mm (1.750 inches) - 1U intervals, creates two slots per U
- **Rail material**: Laser Cut Metal or Plastic or 3D Printed
- **Rail height**: 11mm 

*Design rationale: Slots spaced at 1U intervals (44.45mm) work for both vertical structural support and horizontal panel mounting. For horizontal rails, panels mount across multiple slots. For vertical rails, the 1U spacing provides consistent mounting points.*

#### Rail Configurations

A rail consists of alternating slots and supports, with supports spaced every 1U (44.45mm). This creates **two slots per 1U interval**. Optional mounting holes can be added on either side for structural assembly.

The **same rail design** works for both cross beams (horizontal) and side beams (vertical):
- **Cross beams**: Panels mount horizontally across multiple slots, aligning with HP widths
- **Side beams**: Vertical mounting uses 1U-spaced slots for consistent panel positioning

Rails are used for sides and cross beams, while panels are mounted between cross beams.

*Rail as cross beam (horizontal orientation)*

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 305" role="img" aria-labelledby="cross-title cross-desc">
  <title id="cross-title">MakerRail used as a horizontal cross beam</title>
  <desc id="cross-desc">Flat rail with separate elongated through-slots and solid ribs, not a continuous groove. Callouts show the listed 19.125 mm slot width, 6.2 mm slot height, 6.2 mm support width, and 11 mm rail height. Schematic, not to scale.</desc>
  <text x="24" y="34" class="diagram-heading">06 / HORIZONTAL MAKERRAIL</text>
  <path class="diagram-rail" fill-rule="evenodd" d="M52 128H437V194H52ZM82 143V179H162V143ZM189 143V179H269V143ZM296 143V179H376V143Z"/>
  <circle cx="66" cy="161" r="4"/><circle cx="420" cy="161" r="4"/>
  <path class="diagram-dimension" d="M82 91v18m0 -9h80m0 -9v18M162 222v18m0 -9h27m0 -9v18M23 128h16m-8 0v66m-8 0h16"/>
  <path class="diagram-guide" d="M82 109v34m80 -34v34M162 179v43m27 -43v43"/>
  <text x="82" y="78" class="diagram-value">19.125 mm slot</text>
  <path d="M336 179v38h67"/>
  <text x="295" y="245">6.2 mm</text>
  <text x="295" y="269" class="diagram-muted">slot height</text>
  <text x="76" y="269">6.2 mm support</text>
  <text transform="translate(19 161) rotate(-90)" text-anchor="middle">11 mm</text>
</svg>
<figcaption><strong>Open slots, solid ribs.</strong> These are through-openings in a flat rail, not T-track channels. Nominal dimensions from the specification; schematic, not a cutting template.</figcaption>
</figure>

*Rail as Side Beam (vertical orientation)*

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 370" role="img" aria-labelledby="side-title side-desc">
        <title id="side-title">The same MakerRail turned vertically</title>
        <desc id="side-desc">A vertical rail has the same discrete through-slots and intervening ribs as the horizontal rail. The slot long dimension is 19.125 mm and short dimension 6.2 mm. The overall rail width in this orientation is 11 mm.</desc>
        <text x="24" y="34" class="diagram-heading">07 / VERTICAL MAKERRAIL</text>
        <path class="diagram-rail" fill-rule="evenodd" d="M61 70H127V325H61ZM76 91V149H112V91ZM76 171V229H112V171ZM76 251V309H112V251Z"/>
        <path class="diagram-dimension" d="M61 340v16m0 -8h66m0 -8v16M144 91h16m-8 0v58m-8 0h16"/>
        <path class="diagram-guide" d="M112 120h32M127 160h52M112 201h67"/>
        <text x="179" y="115" class="diagram-value">19.125 mm</text>
        <text x="179" y="139" class="diagram-muted">Slot long dimension</text>
        <text x="179" y="179">6.2 mm support</text>
        <text x="179" y="225">6.2 mm slot opening</text>
        <text x="179" y="286" class="diagram-value">Same profile.</text>
        <text x="179" y="311">Either orientation.</text>
        <text x="145" y="355">11 mm rail</text>
</svg>
<figcaption><strong>Rotate the rail, not the rules.</strong> Use the same slotted profile for side beams and cross beams. Diagram shows orientation only; verify slot pitch against the reference design.</figcaption>
</figure>
*Pattern repeats every 1U (44.45mm) with two slots per U interval*



#### Mounting Hardware

<figure class="spec-diagram">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 390" role="img" aria-labelledby="hardware-title hardware-desc">
        <title id="hardware-title">MakerRail screw, panel, rail and twist nut</title>
        <desc id="hardware-desc">Exploded side section: screw head at the front, then panel, flat slotted rail, and a matching twist nut behind the rail. The nut engages both slot edges. Leave room behind the rail to insert and turn it.</desc>
        <text x="24" y="34" class="diagram-heading">08 / MAKERRAIL HARDWARE</text>
        <path class="diagram-guide" d="M135 62V345"/>
        <rect class="diagram-rail" x="105" y="66" width="60" height="18" rx="4"/>
        <rect class="diagram-rail" x="129" y="84" width="12" height="48"/>
        <path class="diagram-panel" d="M49 157H128V173H49ZM142 157H221V173H142Z"/>
        <path class="diagram-rail" d="M49 218H110V238H49ZM160 218H221V238H160Z"/>
        <path class="diagram-rail" d="M91 284H129V298H141V284H179V314H91Z"/>
        <path class="diagram-guide" d="M166 75H248M222 165H248M222 228H248M180 298H248"/>
        <text x="261" y="81">Matching screw</text>
        <text x="261" y="171">Panel</text>
        <text x="261" y="234">Flat slotted rail</text>
        <text x="261" y="304">Twist nut</text>
        <text x="24" y="363" class="diagram-muted">Allow space behind the rail to insert + turn</text>
</svg>
<figcaption><strong>Clamp across the slot edges.</strong> The panel is in front of the rail; the nut sits behind it. Match screw thread, nut body, slot opening and rail thickness. Exploded schematic, not to scale.</figcaption>
</figure>

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