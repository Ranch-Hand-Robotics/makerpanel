---
title: OpenSCAD
---

# OpenSCAD

The MakerPanel OpenSCAD library is the reference implementation for creating
parametric panels, rails, and rack components. It can generate both 2D profiles
for laser cutting and 3D solids for printing or CAD interchange.

## Recommended editor

We recommend using the Robot Developer Extensions URDF editor for VS Code. Its
OpenSCAD support provides direct `.scad` editing, automatic 3D previews,
Customizer controls, library-path integration, and STL/SVG export. See
[OpenSCAD - Robot Developer Extensions for URDF editing](https://ranchhandrobotics.com/rde-urdf/OpenSCAD.html)
for installation and usage details.

## Requirements

- [OpenSCAD](https://openscad.org/downloads.html)
- Git, or a downloaded copy of the
  [MakerPanel repository](https://github.com/Ranch-Hand-Robotics/makerpanel)
- Windows, Linux, or macOS

## Installation

1. Download or clone the repository:

    ```bash
    git clone https://github.com/Ranch-Hand-Robotics/makerpanel.git
    ```

2. Add the repository's `makerpanel/` directory to your OpenSCAD library path,
   or keep your design inside this repository and use a relative `include`.

3. Confirm the library is available by opening a new file and including the
   panel API:

    ```scad
    include <makerpanel/panel.scad>
    ```

When using VS Code with the URDF Editor extension, this repository already
configures `makerpanel/` as an OpenSCAD library path in `.vscode/settings.json`.

## Create a panel

The primary APIs are:

- `makerpanel_2d(width_hp, height_u)` — a 2D profile for SVG or DXF export
- `makerpanel(width_hp, height_u, thickness)` — a 3D printable/extrudable panel

A minimal configurable panel looks like this:

```scad
include <makerpanel/panel.scad>

/* [Customization] */
horizontalPitch = 8; // [1:1:64]
verticalUnits = 1;   // [0.125:0.125:5]
panelThickness = 3;  // [1:0.5:6]

/* [Part Selection] */
part = "panel_3d"; // [panel_3d, panel_2d]

if (part == "panel_2d") {
    makerpanel_2d(horizontalPitch, verticalUnits);
} else {
    makerpanel(horizontalPitch, verticalUnits, panelThickness);
}
```

Open the file in OpenSCAD, adjust the values in the Customizer, and render the
selected part.

## Export files

- Select `panel_3d`, render with **F6**, then use **File → Export → Export as
  STL** for 3D printing.
- Select `panel_2d`, render with **F6**, then export as **SVG** or **DXF** for
  laser cutting or import into another CAD package.

## Add controls and cutouts

Use `difference()` to subtract component openings from the standard panel body.
Keep component dimensions in named variables so the design remains easy to
adapt and verify.

```scad
include <makerpanel/panel.scad>

module control_panel() {
    difference() {
        makerpanel(12, 1, 3);
        translate([0, 0, -1])
            cylinder(h=5, d=7, $fn=48);
    }
}

control_panel();
```

## Library modules

| File | Purpose |
|------|---------|
| `makerpanel/common.scad` | HP/U conversions and shared dimensions |
| `makerpanel/panel.scad` | Standard 2D and 3D MakerPanel bodies |
| `makerpanel/rails.scad` | MakerRail profiles and extrusions |
| `makerpanel/rack.scad` | 10-inch, 19-inch, and custom rack geometry |

Browse the repository's [`examples/`](https://github.com/Ranch-Hand-Robotics/makerpanel/tree/main/examples)
directory for complete designs with Customizer controls and part selectors.

## Verify your design

Before manufacturing, check the design against the
[MakerPanel specification](specification.md), especially:

- HP and U dimensions
- mounting-hole placement
- panel thickness and component depth
- T-slot rail and fastener compatibility
