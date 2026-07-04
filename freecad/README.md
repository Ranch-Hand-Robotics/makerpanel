# MakerPanel FreeCAD Workbench

This folder contains a FreeCAD workbench that mirrors the Fusion 360 MakerPanel add-in.

## Installation

1. Close FreeCAD.
2. Copy `freecad\MakerPanel` into your FreeCAD Mod directory:
   - Windows: `%APPDATA%\FreeCAD\Mod\MakerPanel`
   - Linux: `~/.local/share/FreeCAD/Mod/MakerPanel`
   - macOS: `~/Library/Preferences/FreeCAD/Mod/MakerPanel`
3. Restart FreeCAD.
4. Select the **MakerPanel** workbench from the workbench selector.

## Included commands

- **Create Panel**: Generates a centred MakerPanel outline sketch with optional mounting holes/slots.
- **Create Rail**: Generates a MakerRail sketch with T-slot cut-outs and optional end holes.

## Documentation

Full usage documentation is available on the project site:
<https://ranch-hand-robotics.github.io/makerpanel/freecad.html>

## Development notes

- FreeCAD uses millimetres internally, so all geometry in this workbench is defined in mm.
- The workbench entry point is `MakerPanel\InitGui.py`.
- Toolbar icons live in `MakerPanel\resources\icons\`.
