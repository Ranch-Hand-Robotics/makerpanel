# Fusion 360 Add-in

<div class="tool-availability-notice">
  <strong>Coming Soon</strong>
  <span>The Fusion 360 add-in is under development. This guide describes the planned installation and workflow.</span>
</div>

The MakerPanel Fusion 360 add-in generates spec-compliant 2D sketches for panels and rails directly inside Autodesk Fusion 360. Each command produces a parametric sketch on the XY plane of the active component, ready for extrusion, DXF export, or further detailing.

## Requirements

- Autodesk Fusion 360 (any current release)
- Windows or macOS

## Installation

1. **Download or clone** the repository:

    ```
    git clone https://github.com/Ranch-Hand-Robotics/makerpanel.git
    ```

2. **Locate the add-ins folder** for your platform:

    | Platform | Path |
    |----------|------|
    | Windows | `%APPDATA%\Autodesk\Autodesk Fusion 360\API\AddIns` |
    | macOS | `~/Library/Application Support/Autodesk/Autodesk Fusion 360/API/AddIns` |

3. **Copy or symlink** the `fusion/` folder from the repo into the add-ins folder and rename it `MakerPanel`:

    ```
    # Windows (PowerShell) — symlink keeps it in sync with the repo
    New-Item -ItemType Junction `
      -Path "$env:APPDATA\Autodesk\Autodesk Fusion 360\API\AddIns\MakerPanel" `
      -Target "S:\ws\makerpanel\fusion"

    # macOS — symlink
    ln -s /path/to/makerpanel/fusion \
      ~/Library/Application\ Support/Autodesk/Autodesk\ Fusion\ 360/API/AddIns/MakerPanel
    ```

4. **Load the add-in** in Fusion 360:
    - Open the **Tools** menu → **Add-Ins** (or press `Shift+S`)
    - Switch to the **Add-Ins** tab
    - Find **MakerPanel** in the list and click **Run**
    - Check **Run on Startup** to load it automatically every session

Once loaded, two new commands appear in the **Sketch** toolbar panel, next to **Create Sketch**:

- **MakerPanel Panel** — generate a panel outline
- **MakerPanel Rail** — generate a rail cross-beam outline

## MakerPanel Panel

Creates a 2D sketch of a panel outline with optional T-slot mounting features.

### Dialog Options

| Option | Description |
|--------|-------------|
| **Width (HP)** | Panel width in Horizontal Pitch units. 1 HP = 5.08 mm. |
| **Height Preset** | Choose **1U** (44.45 mm), **3U Panel** (128.5 mm), or **Custom**. |
| **Custom Height** | Visible only when *Custom* is selected. Enter any height in your active document units. |
| **Add Mounting Slots** | Adds oblong or circular mounting features for T-slot rail attachment. |
| **Slot Style** | **Oblong** — elongated adjustment slots that allow ±2.5 mm of positioning freedom. **Circular** — standard fixed clearance holes. |
| **Show Live Preview** | Renders the sketch in the viewport as you adjust values. Requires parametric (timeline) design mode. |

### Mounting Slot Layout

Mounting features are placed at the top and bottom edges of the panel, inset `2 mm` from the edge. The leftmost and rightmost slots are anchored `2 mm` from each side edge. Additional slots are placed at `25 mm` intervals along the width.

## MakerPanel Rail

Creates a 2D sketch of a horizontal cross-rail with T-slot compatible slot cutouts.

### Dialog Options

| Option | Description |
|--------|-------------|
| **Width (HP)** | Rail length in HP units. Sets the default total length. |
| **Rail Strip Height** | Physical height of the rail strip in mm (default 11 mm). Must exceed the slot height of 6.9 mm. |
| **Override Total Length** | Ignores the HP-derived length and uses a custom value instead. |
| **Custom Total Length** | Visible only when the override is enabled. |
| **Add End Mounting Holes** | Adds M3/M4/M5/M6 clearance holes centred in the solid supports at each end of the rail. |
| **Screw Size** | Selects the end-hole diameter: M3 (3.5 mm), M4 (4.3 mm), M5 (5.3 mm), or M6 (6.4 mm). |
| **90 Degree (vertical)** | Draws the rail with its length along the Y axis instead of the X axis. Useful when placing rails vertically in an assembly sketch. |
| **Show Live Preview** | Renders the sketch in the viewport as you adjust values. |

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

Slots are centred vertically within the rail height and distributed evenly between the end margins.

## Saving Defaults

Each command remembers your last-used values between sessions. Use the **Settings** section in the dialog to:

- **Save** — write the current inputs as new defaults
- **Reset** — restore the previously saved defaults
- **Factory Reset** — clear all saved defaults and return to built-in values
