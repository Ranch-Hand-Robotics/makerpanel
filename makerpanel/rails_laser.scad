// rails_laser.scad
// 2D rail profile for laser cutting (SVG/DXF export)

include <common.scad>
use <rails.scad>

// ---- Configure output ----
rail_width_hp = 24;                // rail length in HP units
rail_height = RACK_RAIL_HEIGHT;    // rail height in mm
mounting_holes = true;             // include mounting holes

rail_width_mm = hp_to_mm(rail_width_hp);

// Render 2D for SVG/DXF export (File -> Export -> Export as SVG/DXF)
maker_rail_2d(rail_width_mm, rail_height, mounting_holes);
