include <common.scad>


// ============================================
// Module: M-LOK Horizontal Cross-Rail
// ============================================

module mlok_crossrail(width, height=15, depth=12) {
    /*
    Creates an M-LOK compatible horizontal cross-rail
    Parameters:
      - width: rail length in mm
      - height: rail height in mm
      - depth: rail depth (front to back) in mm
    */
    
    // Calculate number of slots that fit in the width
    num_slots = floor((width - 20) / MLOK_SLOT_SPACING);
    first_slot_pos = (width - (num_slots - 1) * MLOK_SLOT_SPACING) / 2;
    
    difference() {
        // Base solid block
        cube([width, height, depth], center=false);
        
        // Cut M-LOK slots
        for (i = [0 : num_slots - 1]) {
            x_pos = first_slot_pos + i * MLOK_SLOT_SPACING;
            translate([x_pos, -1, depth/2 - MLOK_SLOT_WIDTH/2])
                cube([MLOK_SLOT_WIDTH, height + 2, MLOK_SLOT_WIDTH], center=false);
        }
    }
}

// ============================================
// Module: Rack Rail (Single)
// ============================================

module rack_rail(height) {
    /*
    Creates a single vertical rack rail with mounting holes
    Parameters:
      - height: rail height in mm (typically multiple of U)
    */
    
    // Calculate number of holes
    num_holes = floor(height / RACK_HOLE_SPACING);
    
    difference() {
        // Base rail
        cube([RACK_RAIL_WIDTH, height, RACK_RAIL_DEPTH]);
        
        // Mounting holes
        hole_start = RACK_HOLE_SPACING / 2;
        for (i = [0 : num_holes - 1]) {
            y_pos = hole_start + i * RACK_HOLE_SPACING;
            translate([RACK_RAIL_WIDTH/2, y_pos, -1])
                cylinder(r=RACK_HOLE_DIAMETER/2, h=RACK_RAIL_DEPTH + 2);
        }
    }
}

// ============================================
// Module: 19" Rack Assembly
// ============================================

module rack_19(height) {
    /*
    Creates a complete 19" rack frame
    Parameters:
      - height: total height in mm (typically multiple of U)
    */
    
    // Left rail
    translate([0, 0, 0])
        rack_rail(height);
    
    // Right rail
    translate([RACK_19_WIDTH - RACK_RAIL_WIDTH, 0, 0])
        rack_rail(height);
    
    // Top horizontal support
    translate([RACK_RAIL_WIDTH, height - 20, 0])
        cube([RACK_19_USABLE, 20, RACK_RAIL_DEPTH]);
    
    // Bottom horizontal support
    translate([RACK_RAIL_WIDTH, 0, 0])
        cube([RACK_19_USABLE, 20, RACK_RAIL_DEPTH]);
    
    // Back panel (optional - comment out if not needed)
    %translate([0, 0, RACK_RAIL_DEPTH - 2])
        cube([RACK_19_WIDTH, height, 2]);
}

// ============================================
// Module: 10" Rack Assembly
// ============================================

module rack_10(height) {
    /*
    Creates a complete 10" rack frame
    Parameters:
      - height: total height in mm (typically multiple of U)
    */
    
    rack_width = RACK_10_WIDTH;
    usable = RACK_10_USABLE;
    
    // Left rail
    translate([0, 0, 0])
        rack_rail(height);
    
    // Right rail
    translate([rack_width - RACK_RAIL_WIDTH, 0, 0])
        rack_rail(height);
    
    // Top support
    translate([RACK_RAIL_WIDTH, height - 20, 0])
        cube([usable, 20, RACK_RAIL_DEPTH]);
    
    // Bottom support
    translate([RACK_RAIL_WIDTH, 0, 0])
        cube([usable, 20, RACK_RAIL_DEPTH]);
    
    // Back panel (optional)
    %translate([0, 0, RACK_RAIL_DEPTH - 2])
        cube([rack_width, height, 2]);
}

// ============================================
// Module: Custom Width Rack
// ============================================

module rack_custom(width, height) {
    /*
    Creates a rack with custom width
    Parameters:
      - width: outer width in mm
      - height: height in mm
    */
    
    usable = width - 2 * RACK_RAIL_WIDTH;
    
    // Left rail
    translate([0, 0, 0])
        rack_rail(height);
    
    // Right rail
    translate([width - RACK_RAIL_WIDTH, 0, 0])
        rack_rail(height);
    
    // Top support
    translate([RACK_RAIL_WIDTH, height - 20, 0])
        cube([usable, 20, RACK_RAIL_DEPTH]);
    
    // Bottom support
    translate([RACK_RAIL_WIDTH, 0, 0])
        cube([usable, 20, RACK_RAIL_DEPTH]);
    
    // Back panel (optional)
    %translate([0, 0, RACK_RAIL_DEPTH - 2])
        cube([width, height, 2]);
}
