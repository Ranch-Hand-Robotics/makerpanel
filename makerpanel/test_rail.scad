use <rails.scad>
use <panel.scad>

/* [Part Selection] */
part = "rail"; // [rail,panel]

/* [Parameters] */
hp = 35; // Horizontal pitch for the rail or Panel(in HP units)
u = 1; // Height for the Panel (in U units)
holes = true; // Include mounting holes in the rail

if (part == "rail") {
	maker_rail(hp, mounting_holes=holes);
} else {
	makerpanel(hp, u);
}