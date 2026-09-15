# Example part selectors

Every panel sample uses the exact selector `part = "makerpanel"` for its
3D mounting/measuring base, without attached preview components or separate
fabrication parts. Existing assembly defaults remain `assembly`; standalone
base defaults are `makerpanel`. Geometry module names have not been renamed:
the shared library already defines `makerpanel()`.

| Sample | Default | Other Customizer outputs (unchanged) |
| --- | --- | --- |
| [Antenna](Antenna/antenna.scad) | `assembly` | `assembly`, `panel_2d` |
| [Iris](iris_keyboard/IrisMakerPanel.scad) | `assembly` | `assembly`, `iris_keyboard_laser` |
| [Joystick](joystick/design/joystick.scad) | `assembly` | `assembly`, `panel_2d` |
| [LilyGo screen](lilygo_screen_4_7_s3/lilygo_screen.scad) | `assembly` | `assembly`, `lilygo_screen`, `lilygo_pcb` |
| [LilyGo encoder](lilygo_t-encoder-pro/design/lilygo_t-encoder-pro.scad) | `makerpanel` | None |
| [Measurement gauge](measure/measure.scad) | `makerpanel` | `rail`, `rack` (not implemented) |
| [Monitor](monitor_panel/monitor.scad) | `assembly` | `assembly`, `vesa_panel`, `brace`, `brace_2d` |
| [Mouse pad](mouse_panel/MousePadPanel.scad) | `makerpanel` | `mousepad_panel_laser`, `assembly` |
| [Power](power_panel/PowerPanel.scad) | `makerpanel` | `panel_2d` |
| [Prime79](prime79_panel/prime97_panel.scad) | `assembly` | `assembly`, `prime79_keyboard_laser` |
| [Rack faceplate](rail_panel/RailPanel.scad) | `makerpanel` | `rail_panel_2d` |
| [Stream Deck](streamdeck_panel/streamdeck_panel.scad) | `assembly` | `assembly`, `bottom` |
| [Switch](switch_panel/switch_panel.scad) | `assembly` | `assembly`, `panel_2d` |
| [Trackball](trackball_panel/trackball_panel.scad) | `makerpanel` | `panel_2d`, `assembly`, `footprint` |
| [Vent](vent_panel/VentPanel.scad) | `makerpanel` | `panel_2d` |

The monitor also retains its scripted pose, hardware, and pad outputs listed
in its [README](monitor_panel/README.md#exports-and-validation). All existing
2D selector names remain unchanged. Former 3D base selector names are not
aliases; use `makerpanel` when scripting these samples.

## Coordinates and scope

Assembly and `makerpanel` use the same primary base coordinates. Iris keeps
one panel at the standalone origin and places its mirrored companion one
panel width along +X. This translates the former centered-pair preview by
half a panel width without changing either half or their relative placement.
Trackball keeps its panel untransformed in both outputs; only the background
footprint sits below the panel. The measurement gauge keeps its existing
corner origin and is a reference tool, not a rail-mountable panel.

`keyboard/cmx.scad` and `keyboard/kinst_mf34.scad` are keycap/keyboard helpers,
not mounting panels. They and vendored `vent_panel/IsoGridScad` are excluded.
No HP/U dimensions, mounting holes, clearances, or fabrication geometry are
redefined by this selector convention.

## Source regression checks

From the repository root, run `node.exe --test examples/part-selectors.test.cjs`.
These checks cover the complete sample inventory, defaults, Customizer options,
base dispatch, retained outputs, and source-level assembly/base alignment.
They do not compile SCAD or certify meshes, fit, or strength. Use the URDF
renderer for screenshot and geometry validation when available.