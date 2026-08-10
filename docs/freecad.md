# FreeCAD Workbench

<div class="tool-availability-notice">
  <strong>Coming Soon</strong>
  <span>The FreeCAD workbench is under development. This guide describes the planned installation and workflow.</span>
</div>

The MakerPanel FreeCAD workbench generates spec-compliant 2D sketches for panels and rails directly inside FreeCAD. Each command produces a Sketcher sketch on the XY plane of the active document, ready for padding (extrusion), DXF export, or further detailing.

## Requirements

- FreeCAD 0.21 or later (PySide2); FreeCAD 1.0+ (PySide6) also supported
- Windows, Linux, or macOS

## Installation

1. **Download or clone** the repository:

    ```
    git clone https://github.com/Ranch-Hand-Robotics/makerpanel.git
    ```

2. **Locate the Mod folder** for your platform:

    | Platform | Path |
    |----------|------|
    | Windows | `%APPDATA%\FreeCAD\Mod\` |
    | Linux | `~/.local/share/FreeCAD/Mod/` |
    | macOS | `~/Library/Preferences/FreeCAD/Mod/` |

3. **Copy or symlink** the `freecad/MakerPanel` folder from the repo into the Mod folder:

    ```
    # Windows (PowerShell) — symlink keeps it in sync with the repo
    New-Item -ItemType Junction `
      -Path "$env:APPDATA\FreeCAD\Mod\MakerPanel" `
      -Target "C:\path\to\makerpanel\freecad\MakerPanel"

    # Linux / macOS — symlink
    ln -s /path/to/makerpanel/freecad/MakerPanel \
      ~/.local/share/FreeCAD/Mod/MakerPanel
    ```

4. **Restart FreeCAD** and select the **MakerPanel** workbench from the workbench selector dropdown.

Once activated, both commands are available in the **MakerPanel** menu and the **MakerPanel Tools** toolbar:

- **Create Panel** — generate a panel outline sketch
- **Create Rail** — generate a rail cross-beam sketch

## MakerPanel Panel

Creates a 2D sketch of a panel outline with optional T-slot mounting features.

### Task Panel Options

| Option | Description |
|--------|-------------|
| **Width (HP)** | Panel width in Horizontal Pitch units. 1 HP = 5.08 mm. Range: 1–64. |
| **Height** | Choose a preset: **1U** (44.45 mm) through **5U** (222.25 mm), or **Custom**. |
| **Custom Height** | Visible only when *Custom* is selected. Enter any height in mm. |
| **Add mounting slots** | Adds oblong or circular mounting features for T-slot rail attachment. |
| **Slot style** | **Oblong** — elongated adjustment slots that allow ±2.5 mm of positioning freedom. **Circular** — standard fixed clearance holes (3.2 mm diameter). |
| **Mounting density** | **Full** — slots at every 25 mm interval. **Minimal** — left edge, centre, and right edge only. |

### Mounting Slot Layout

Mounting features are placed at the top and bottom edges of the panel, inset `2 mm` from the edge. The leftmost and rightmost slots are anchored `2 mm` from each side edge. In *Full* mode, additional slots are evenly distributed at approximately `25 mm` intervals along the width. In *Minimal* mode, only the two edges and a centre slot are placed.

### Sketch Behaviour

- The panel is centred at the origin (0, 0) of the sketch.
- If you are actively editing a sketch when the command runs, geometry is added to that sketch instead of creating a new one.
- After creation, the view automatically fits to show the full panel.

## MakerPanel Rail

Creates a 2D sketch of a horizontal cross-rail with T-slot compatible slot cutouts.

### Task Panel Options

| Option | Description |
|--------|-------------|
| **Width (HP)** | Rail length in HP units. Sets the default total length. Range: 1–400. |
| **Rail height** | Physical height of the rail strip in mm (default 11 mm). Must exceed the slot height of 6.9 mm. |
| **Override length** | When checked, ignores the HP-derived length and uses a custom value. |
| **Custom length** | Editable when the override is enabled. Enter any total length in mm. |
| **Add end holes** | Adds clearance holes centred in the solid supports at each end of the rail. |
| **Hole size** | Selects the end-hole diameter: M3 (3.5 mm), M4 (4.3 mm), M5 (5.3 mm), or M6 (6.4 mm). |
| **Rotate 90°** | Draws the rail with its length along the Y axis instead of the X axis. Useful for vertical rail placement. |

### Slot Algorithm

The slot geometry mirrors the OpenSCAD reference implementation (`rails.scad`):

```
end_margin    = rail_height          (if end holes enabled)
              = 3 mm                 (if end holes disabled)
available     = total_length − 2 × end_margin
min_pitch     = 29.21 mm + 3 mm      (slot min width + support width)
num_slots     = floor((available + 3) / min_pitch)
actual_slot_w = (available − (num_slots − 1) × 3) / num_slots
```

Slots are centred vertically within the rail height and have rounded corners (1 mm radius). They are distributed evenly between the end margins.

### Sketch Behaviour

- The rail origin is at (0, 0) — the bottom-left corner of the outer rectangle.
- When *Rotate 90°* is checked, the rail's length runs along Y and height along X.
- End holes are centred in the square end-support regions.

## Comparison with the Fusion 360 Add-in

Both tools produce identical geometry from the same specification constants. The main differences are in their host environments:

| Aspect | Fusion 360 Add-in | FreeCAD Workbench |
|--------|-------------------|-------------------|
| Internal units | Centimetres | Millimetres |
| UI framework | Fusion CommandInputs | PySide (Qt) task panels |
| Sketch API | `adsk.fusion.Sketch` | `Sketcher::SketchObject` + `Part` |
| Save/reset defaults | Built-in JSON persistence | Not yet implemented |
| Live preview | Yes (parametric mode) | Not yet implemented |
| Platform | Windows, macOS | Windows, Linux, macOS |

## Troubleshooting

**Workbench not visible in the selector:**
Ensure the `MakerPanel` folder (containing `InitGui.py`) is directly inside the Mod directory — not nested in an extra subfolder.

**Import errors on startup:**
Check the FreeCAD Report View (View → Panels → Report View) for Python tracebacks. The workbench requires FreeCAD 0.21+ for PySide2 support.

**Commands greyed out:**
Both commands require an active document. Create or open a document first (File → New).
