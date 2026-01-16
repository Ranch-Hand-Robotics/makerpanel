// Makerpanel System OpenSCAD Models
// Modular maker panel system with rack mounting support
// All dimensions in millimeters

// ============================================
// Constants
// ============================================

// Panel Units
HP = 5.08;           // Horizontal Pitch = 5.08mm (0.200")
U = 44.45;           // Vertical Unit = 44.45mm (1.75")

// M-LOK Specifications
MLOK_SLOT_WIDTH = 6.2;      // M-LOK slot width
MLOK_SLOT_SPACING = 13;     // Center-to-center spacing
MLOK_SLOT_DEPTH = 4;        // Depth of slot cutout

// Rack Specifications
RACK_HOLE_SPACING = 25.4;   // Standard EIA-310-D (1" = 25.4mm) = 5 HP
RACK_HOLE_DIAMETER = 6.5;   // M6 mounting holes (standard 19" rack)
RACK_RAIL_WIDTH = 19;       // Standard rack rail width
RACK_RAIL_DEPTH = 35;       // Standard rack rail depth
RACK_RAIL_THICKNESS = 3;    // Rail material thickness

// Rack Widths
RACK_19_WIDTH = 465.1;      // 19" rack outer width
RACK_19_USABLE = 432;       // 19" usable width (between rails)
RACK_10_WIDTH = 254;        // 10" rack outer width (approx)
RACK_10_USABLE = 203;       // 10" usable width (between rails)

// Panel Specifications
PANEL_THICKNESS = 3;        // Aluminum panel thickness
PANEL_DEPTH_MAX = 60;       // Maximum panel depth from front
MOUNT_HOLE_DIAMETER = 3.5;  // M3 mounting hole (for T-nuts)

// ============================================
// Utility Functions
// ============================================

// Convert HP to millimeters
function hp_to_mm(hp) = hp * HP;

// Convert U to millimeters
function u_to_mm(u) = u * U;

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

// ============================================
// Module: Panel with M-LOK Mounting Holes
// ============================================

module makerpanel(width_hp, height_u, thickness=PANEL_THICKNESS) {
    /*
    Creates a maker panel with M-LOK mounting holes
    Parameters:
      - width_hp: width in HP units
      - height_u: height in U units
      - thickness: panel thickness in mm (default 3mm aluminum)
    */
    
    width_mm = hp_to_mm(width_hp);
    height_mm = u_to_mm(height_u);
    
    // Calculate mounting hole positions
    // Holes positioned to align with M-LOK slot centers (13mm spacing)
    hole_spacing = MLOK_SLOT_SPACING;
    num_holes_h = floor(width_mm / hole_spacing);
    num_holes_v = max(1, floor(height_mm / hole_spacing));
    
    hole_start_x = (width_mm - (num_holes_h - 1) * hole_spacing) / 2;
    hole_start_y = (height_mm - (num_holes_v - 1) * hole_spacing) / 2;
    
    difference() {
        // Base panel
        cube([width_mm, height_mm, thickness], center=false);
        
        // M-LOK mounting holes (vertical holes for T-nuts)
        for (i = [0 : num_holes_h - 1]) {
            for (j = [0 : num_holes_v - 1]) {
                x_pos = hole_start_x + i * hole_spacing;
                y_pos = hole_start_y + j * hole_spacing;
                
                // Only create holes near edges (2cm border minimum)
                if (x_pos >= 20 && x_pos <= width_mm - 20 &&
                    y_pos >= 20 && y_pos <= height_mm - 20) {
                    translate([x_pos, y_pos, -1])
                        cylinder(r=MOUNT_HOLE_DIAMETER/2, h=thickness + 2);
                }
            }
        }
    }
}

// ============================================
// Example Assemblies
// ============================================

// Example 1: 19" Rack with panels
module example_19_rack() {
    // Create 19" rack (6U height = 267mm)
    rack_19(u_to_mm(6));
    
    // Add cross-rails at 1U and 4U positions
    translate([RACK_RAIL_WIDTH, u_to_mm(1), RACK_RAIL_DEPTH - 15])
        mlok_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(4), RACK_RAIL_DEPTH - 15])
        mlok_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    // Add sample panels
    translate([RACK_RAIL_WIDTH + 20, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);  // 8 HP × 1U panel
    
    translate([RACK_RAIL_WIDTH + 150, u_to_mm(4.5), RACK_RAIL_DEPTH])
        %makerpanel(6, 1);  // 6 HP × 1U panel
}

// Example 2: 10" Rack with panels
module example_10_rack() {
    // Create 10" rack (6U height)
    rack_10(u_to_mm(6));
    
    // Add cross-rails
    translate([RACK_RAIL_WIDTH, u_to_mm(1), RACK_RAIL_DEPTH - 15])
        mlok_crossrail(RACK_10_USABLE, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(4), RACK_RAIL_DEPTH - 15])
        mlok_crossrail(RACK_10_USABLE, height=12, depth=15);
    
    // Add sample panels
    translate([RACK_RAIL_WIDTH + 15, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(6, 1);  // 6 HP × 1U
}

// Example 3: Standalone M-LOK cross-rail system
module example_standalone() {
    // Create a standalone cross-rail system (not rack-mounted)
    
    // Horizontal cross-rail (48 HP wide)
    translate([0, 0, 0])
        mlok_crossrail(hp_to_mm(48), height=12, depth=15);
    
    // Add sample panels
    translate([hp_to_mm(2), 20, 15])
        %makerpanel(8, 3);  // 8 HP × 3U
    
    translate([hp_to_mm(12), 20, 15])
        %makerpanel(12, 3);  // 12 HP × 3U
    
    translate([hp_to_mm(26), 20, 15])
        %makerpanel(16, 3);  // 16 HP × 3U
}

// ============================================
// Render Selection
// ============================================

// Uncomment the example you want to view:

// example_19_rack();
// example_10_rack();
example_standalone();

// Or render individual components:
// rack_19(u_to_mm(6));
// mlok_crossrail(hp_to_mm(48), 12, 15);
// makerpanel(8, 3);
