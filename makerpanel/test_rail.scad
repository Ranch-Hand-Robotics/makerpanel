use <rails.scad>
use <panel.scad>

maker_rail(hp_to_mm(24));

translate([-5,10,0])
makerpanel(8, 1);

translate([50,10,0])
makerpanel(12, 1);