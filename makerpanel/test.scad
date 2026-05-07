// Makerpanel Test - Various sizes of panels and hosts
// Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved.
// Licensed under MIT License: https://opensource.org/licenses/MIT
// This test file generates different configurations of panels and mounting systems

include <panel.scad>
include <rails.scad>

/* [Part Selection] */
part = "panel_sizes";// [all,panel_sizes,cross_rail_hosts, rack_19_all,rack_19_small,rack_19_medium,rack_19_large,  rack_10_all,rack_10_small,rack_10_medium,custom_rack,dense_array]

// ============================================
// TEST: Panel Size Variations
// ============================================

module test_panel_sizes() {
    /*
    Displays various panel sizes in different HP and U combinations
    */
    
    // Small panels (1U height)
    translate([0, 0, 0])
        makerpanel(2, 1);  // 2 HP × 1U - smallest standard
    
    translate([hp_to_mm(3), 0, 0])
        makerpanel(4, 1);  // 4 HP × 1U
    
    translate([hp_to_mm(8), 0, 0])
        makerpanel(6, 1);  // 6 HP × 1U
    
    // Medium panels (1U)
    translate([hp_to_mm(16), 0, 0])
        makerpanel(8, 1);  // 8 HP × 1U
    
    translate([hp_to_mm(25), 0, 0])
        makerpanel(12, 1);  // 12 HP × 1U
    
    // Large panels (1U)
    translate([hp_to_mm(38), 0, 0])
        makerpanel(16, 1);  // 16 HP × 1U
    
    translate([hp_to_mm(55), 0, 0])
        makerpanel(20, 1);  // 20 HP × 1U
    
    // 3U tall panels
    translate([0, u_to_mm(2), 0])
        makerpanel(4, 3);  // 4 HP × 3U - compact 3U
    
    translate([hp_to_mm(5), u_to_mm(2), 0])
        makerpanel(8, 3);  // 8 HP × 3U
    
    translate([hp_to_mm(15), u_to_mm(2), 0])
        makerpanel(12, 3);  // 12 HP × 3U - standard full height
    
    translate([hp_to_mm(28), u_to_mm(2), 0])
        makerpanel(20, 3);  // 20 HP × 3U - large 3U
    
    // Full-size panels
    translate([0, u_to_mm(6), 0])
        makerpanel(8, 6);  // 8 HP × 6U
    
    translate([hp_to_mm(10), u_to_mm(6), 0])
        makerpanel(12, 6);  // 12 HP × 6U
    
    translate([hp_to_mm(24), u_to_mm(6), 0])
        makerpanel(20, 6);  // 20 HP × 6U
}

// ============================================
// TEST: T-Slot Cross-Rail Hosts
// ============================================

module test_maker_rails() {
    /*
    Displays T-slot cross-rails (M5/M6 compatible) of various widths
    */
    
    // 24 HP wide rail (122mm)
    translate([0, 0, 0])
        maker_rail(hp_to_mm(24));
    
    // 36 HP wide rail (183mm)
    translate([0, u_to_mm(1), 0])
        maker_rail(hp_to_mm(36));
    
    // 48 HP wide rail (244mm)
    translate([0, u_to_mm(2), 0])
        maker_rail(hp_to_mm(48));
    
    // Full 19" usable width
    translate([0, u_to_mm(3), 0])
        maker_rail(RACK_19_WIDTH);
}

// ============================================
// TEST: Standalone Cross-Rail Systems
// ============================================

module test_standalone_systems() {
    /*
    Complete standalone systems with cross-rails and panels
    */
    
    // System 1: Compact 24 HP setup
    translate([0, 0, 0]) {
        // Cross-rail
        maker_rail(hp_to_mm(24));
        
        // Panels on the rail
        translate([hp_to_mm(2), 20, 15])
            makerpanel(4, 3);
        
        translate([hp_to_mm(8), 20, 15])
            makerpanel(8, 3);
        
        translate([hp_to_mm(16), 20, 15])
            makerpanel(4, 3);
    }
    
    // System 2: Medium 36 HP setup
    translate([0, u_to_mm(4), 0]) {
        // Cross-rail
        maker_rail(hp_to_mm(36));
        
        // Panels on the rail
        translate([hp_to_mm(2), 20, 15])
            makerpanel(6, 3);
        
        translate([hp_to_mm(10), 20, 15])
            makerpanel(8, 3);
        
        translate([hp_to_mm(20), 20, 15])
            makerpanel(8, 3);
    }
    
    // System 3: Large 48 HP setup
    translate([0, u_to_mm(8), 0]) {
        // Cross-rail
        maker_rail(hp_to_mm(48));
        
        // Panels on the rail
        translate([hp_to_mm(2), 20, 15])
            makerpanel(8, 3);
        
        translate([hp_to_mm(12), 20, 15])
            makerpanel(12, 3);
        
        translate([hp_to_mm(26), 20, 15])
            makerpanel(8, 3);
    }
}

// ============================================
// TEST: 19" Rack with Various Configurations
// ============================================

module test_19_rack_small() {
    /*
    19" Rack with minimal height (3U)
    */
    rack_19(u_to_mm(3));
    
    // Add a cross-rail
    translate([0, u_to_mm(1), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_19_WIDTH);
    
    // Add panels
    translate([30, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
    
    translate([100, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(10, 1);
}

module test_19_rack_medium() {
    /*
    19" Rack with medium height (6U)
    */
    rack_19(u_to_mm(6));
    
    // Add cross-rails at multiple positions
    translate([0, u_to_mm(1), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_19_WIDTH);
    
    translate([0, u_to_mm(4), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_19_WIDTH);
    
    // Add panels at different positions
    translate([30, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(6, 1);
    
    translate([85, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
    
    translate([150, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
    
    translate([50, u_to_mm(4.5), RACK_RAIL_THICKNESS])
        makerpanel(12, 1);
    
    translate([140, u_to_mm(4.5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
}

module test_19_rack_large() {
    /*
    19" Rack with large height (10U)
    */
    rack_19(u_to_mm(10));
    
    // Add multiple cross-rails
    translate([0, u_to_mm(1.5), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_19_WIDTH);
    
    translate([0, u_to_mm(4.5), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_19_WIDTH);
    
    translate([0, u_to_mm(7.5), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_19_WIDTH);
    
    // Add varied panel sizes
    translate([30, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
    
    translate([100, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(10, 1);
    
    translate([50, u_to_mm(5), RACK_RAIL_THICKNESS])
        makerpanel(12, 1);
    
    translate([140, u_to_mm(5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
    
    translate([40, u_to_mm(8), RACK_RAIL_THICKNESS])
        makerpanel(16, 1);
}

// ============================================
// TEST: 10" Rack with Various Configurations
// ============================================

module test_10_rack_small() {
    /*
    10" Rack with minimal height (3U)
    */
    rack_10(u_to_mm(3));
    
    // Add a cross-rail
    translate([0, u_to_mm(1), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_10_WIDTH);
    
    // Add panels
    translate([15, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(4, 1);
    
    translate([65, u_to_mm(1.5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
}

module test_10_rack_medium() {
    /*
    10" Rack with medium height (6U)
    */
    rack_10(u_to_mm(6));
    
    // Add cross-rails
    translate([0, u_to_mm(1.5), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_10_WIDTH);
    
    translate([0, u_to_mm(4.5), RACK_RAIL_THICKNESS - 15])
        maker_rail(RACK_10_WIDTH);
    
    // Add panels
    translate([15, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(6, 1);
    
    translate([70, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
    
    translate([25, u_to_mm(5), RACK_RAIL_THICKNESS])
        makerpanel(8, 1);
}

// ============================================
// TEST: Custom Width Rack with Panels
// ============================================

module test_custom_rack() {
    /*
    Custom width rack (useful for non-standard dimensions)
    */
    
    // Custom 36" wide rack (914mm), 6U height
    rack_custom(914, u_to_mm(6));
    
    // Add multiple cross-rails
    translate([0, u_to_mm(1.5), RACK_RAIL_THICKNESS - 15])
        maker_rail(914 - 2*RACK_RAIL_HEIGHT);
    
    translate([0, u_to_mm(4), RACK_RAIL_THICKNESS - 15])
        maker_rail(914 - 2*RACK_RAIL_HEIGHT);
    
    // Add varied panels
    translate([40, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(12, 1);
    
    translate([140, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(16, 1);
    
    translate([280, u_to_mm(2), RACK_RAIL_THICKNESS])
        makerpanel(12, 1);
    
    translate([80, u_to_mm(4.5), RACK_RAIL_THICKNESS])
        makerpanel(20, 1);
    
    translate([240, u_to_mm(4.5), RACK_RAIL_THICKNESS])
        makerpanel(16, 1);
}

// ============================================
// TEST: Dense Panel Arrays
// ============================================

module test_dense_array() {
    /*
    Shows multiple cross-rails stacked to create a dense panel array
    */
    
    // 48 HP wide base with 3 cross-rails stacked
    y_spacing = u_to_mm(1.5);
    
    for (rail = [0 : 2]) {
        translate([0, rail * y_spacing, 0])
            maker_rail(hp_to_mm(48));
    }
    
    // Add panels - filling multiple rows
    
    translate([hp_to_mm(2), y_spacing + 20, 15])
        makerpanel(6, 1);
    
    translate([hp_to_mm(10), y_spacing + 20, 15])
        makerpanel(8, 1);
    
    translate([hp_to_mm(20), y_spacing + 20, 15])
        makerpanel(8, 1);
    
    translate([hp_to_mm(30), y_spacing + 20, 15])
        makerpanel(8, 1);
    
    // Second row
    current_y = 2 * y_spacing;
    
    translate([hp_to_mm(2), current_y + 20, 15])
        makerpanel(8, 1);
    
    translate([hp_to_mm(12), current_y + 20, 15])
        makerpanel(12, 1);
    
    translate([hp_to_mm(26), current_y + 20, 15])
        makerpanel(8, 1);
}

// ============================================
// RENDER SELECTION WITH TEST SWITCHER
// ============================================

// Select which test(s) to render in OpenSCAD Customizer.

// Render selected tests
if (part == "all" || part == "panel_sizes") {
    // Panel size variations
    test_panel_sizes();
}

if (part == "all" || part == "cross_rail_hosts") {
    // T-slot cross-rail hosts of various widths
    test_maker_rails();
}

if (part == "all" || part == "standalone_systems") {
    // Standalone systems
    test_standalone_systems();
}

if (part == "all" || part == "rack_19_all" || part == "rack_19_small") {
    // 19" rack (small)
    test_19_rack_small();
}

if (part == "all" || part == "rack_19_all" || part == "rack_19_medium") {
    // 19" rack (medium)
    test_19_rack_medium();
}

if (part == "all" || part == "rack_19_all" || part == "rack_19_large") {
    // 19" rack (large)
    test_19_rack_large();
}

if (part == "all" || part == "rack_10_all" || part == "rack_10_small") {
    // 10" rack (small)
    test_10_rack_small();
}

if (part == "all" || part == "rack_10_all" || part == "rack_10_medium") {
    // 10" rack (medium)
    test_10_rack_medium();
}

if (part == "all" || part == "custom_rack") {
    // Custom width rack
    test_custom_rack();
}

if (part == "all" || part == "dense_array") {
    // Dense panel array
    test_dense_array();
}

