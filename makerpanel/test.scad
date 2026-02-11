// Makerpanel Test - Various sizes of panels and hosts
// Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved.
// Licensed under MIT License: https://opensource.org/licenses/MIT
// This test file generates different configurations of panels and mounting systems

use <panel.scad>
use <rails.scad>

// ============================================
// TEST 1: Panel Size Variations
// ============================================

module test_panel_sizes() {
    /*
    Displays various panel sizes in different HP and U combinations
    */
    
    // Small panels (1U height)
    translate([0, 0, 0])
        makerpanel(2, 1);  // 2 HP × 1U - smallest standard
    
    translate([hp_to_mm(4), 0, 0])
        makerpanel(4, 1);  // 4 HP × 1U
    
    translate([hp_to_mm(8), 0, 0])
        makerpanel(6, 1);  // 6 HP × 1U
    
    // Medium panels (1U)
    translate([hp_to_mm(14), 0, 0])
        makerpanel(8, 1);  // 8 HP × 1U
    
    translate([hp_to_mm(22), 0, 0])
        makerpanel(12, 1);  // 12 HP × 1U
    
    // Large panels (1U)
    translate([hp_to_mm(34), 0, 0])
        makerpanel(16, 1);  // 16 HP × 1U
    
    translate([hp_to_mm(50), 0, 0])
        makerpanel(20, 1);  // 20 HP × 1U
    
    // 3U tall panels
    translate([0, u_to_mm(2), 0])
        makerpanel(4, 3);  // 4 HP × 3U - compact 3U
    
    translate([hp_to_mm(6), u_to_mm(2), 0])
        makerpanel(8, 3);  // 8 HP × 3U
    
    translate([hp_to_mm(14), u_to_mm(2), 0])
        makerpanel(12, 3);  // 12 HP × 3U - standard full height
    
    translate([hp_to_mm(26), u_to_mm(2), 0])
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
// TEST 2: T-Slot Cross-Rail Hosts
// ============================================

module test_t_slot_crossrails() {
    /*
    Displays T-slot cross-rails (M5/M6 compatible) of various widths
    */
    
    // 24 HP wide rail (122mm)
    translate([0, 0, 0])
        t_slot_crossrail(hp_to_mm(24), height=15, depth=12);
    
    // 36 HP wide rail (183mm)
    translate([0, u_to_mm(1), 0])
        t_slot_crossrail(hp_to_mm(36), height=15, depth=12);
    
    // 48 HP wide rail (244mm)
    translate([0, u_to_mm(2), 0])
        t_slot_crossrail(hp_to_mm(48), height=15, depth=12);
    
    // Full 19" usable width
    translate([0, u_to_mm(3), 0])
        t_slot_crossrail(RACK_19_USABLE, height=15, depth=12);
}

// ============================================
// TEST 3: Standalone Cross-Rail Systems
// ============================================

module test_standalone_systems() {
    /*
    Complete standalone systems with cross-rails and panels
    */
    
    // System 1: Compact 24 HP setup
    translate([0, 0, 0]) {
        // Cross-rail
        t_slot_crossrail(hp_to_mm(24), height=12, depth=15);
        
        // Panels on the rail
        translate([hp_to_mm(2), 20, 15])
            %makerpanel(4, 3);
        
        translate([hp_to_mm(8), 20, 15])
            %makerpanel(8, 3);
        
        translate([hp_to_mm(16), 20, 15])
            %makerpanel(4, 3);
    }
    
    // System 2: Medium 36 HP setup
    translate([0, u_to_mm(4), 0]) {
        // Cross-rail
        t_slot_crossrail(hp_to_mm(36), height=12, depth=15);
        
        // Panels on the rail
        translate([hp_to_mm(2), 20, 15])
            %makerpanel(6, 3);
        
        translate([hp_to_mm(10), 20, 15])
            %makerpanel(8, 3);
        
        translate([hp_to_mm(20), 20, 15])
            %makerpanel(8, 3);
    }
    
    // System 3: Large 48 HP setup
    translate([0, u_to_mm(8), 0]) {
        // Cross-rail
        t_slot_crossrail(hp_to_mm(48), height=12, depth=15);
        
        // Panels on the rail
        translate([hp_to_mm(2), 20, 15])
            %makerpanel(8, 3);
        
        translate([hp_to_mm(12), 20, 15])
            %makerpanel(12, 3);
        
        translate([hp_to_mm(26), 20, 15])
            %makerpanel(8, 3);
    }
}

// ============================================
// TEST 4: 19" Rack with Various Configurations
// ============================================

module test_19_rack_small() {
    /*
    19" Rack with minimal height (3U)
    */
    rack_19(u_to_mm(3));
    
    // Add a cross-rail
    translate([RACK_RAIL_WIDTH, u_to_mm(1), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    // Add panels
    translate([RACK_RAIL_WIDTH + 30, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
    
    translate([RACK_RAIL_WIDTH + 100, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(10, 1);
}

module test_19_rack_medium() {
    /*
    19" Rack with medium height (6U)
    */
    rack_19(u_to_mm(6));
    
    // Add cross-rails at multiple positions
    translate([RACK_RAIL_WIDTH, u_to_mm(1), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(4), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    // Add panels at different positions
    translate([RACK_RAIL_WIDTH + 30, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(6, 1);
    
    translate([RACK_RAIL_WIDTH + 85, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
    
    translate([RACK_RAIL_WIDTH + 150, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
    
    translate([RACK_RAIL_WIDTH + 50, u_to_mm(4.5), RACK_RAIL_DEPTH])
        %makerpanel(12, 1);
    
    translate([RACK_RAIL_WIDTH + 140, u_to_mm(4.5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
}

module test_19_rack_large() {
    /*
    19" Rack with large height (10U)
    */
    rack_19(u_to_mm(10));
    
    // Add multiple cross-rails
    translate([RACK_RAIL_WIDTH, u_to_mm(1.5), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(4.5), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(7.5), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_19_USABLE, height=12, depth=15);
    
    // Add varied panel sizes
    translate([RACK_RAIL_WIDTH + 30, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
    
    translate([RACK_RAIL_WIDTH + 100, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(10, 1);
    
    translate([RACK_RAIL_WIDTH + 50, u_to_mm(5), RACK_RAIL_DEPTH])
        %makerpanel(12, 1);
    
    translate([RACK_RAIL_WIDTH + 140, u_to_mm(5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
    
    translate([RACK_RAIL_WIDTH + 40, u_to_mm(8), RACK_RAIL_DEPTH])
        %makerpanel(16, 1);
}

// ============================================
// TEST 5: 10" Rack with Various Configurations
// ============================================

module test_10_rack_small() {
    /*
    10" Rack with minimal height (3U)
    */
    rack_10(u_to_mm(3));
    
    // Add a cross-rail
    translate([RACK_RAIL_WIDTH, u_to_mm(1), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_10_USABLE, height=12, depth=15);
    
    // Add panels
    translate([RACK_RAIL_WIDTH + 15, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(4, 1);
    
    translate([RACK_RAIL_WIDTH + 65, u_to_mm(1.5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
}

module test_10_rack_medium() {
    /*
    10" Rack with medium height (6U)
    */
    rack_10(u_to_mm(6));
    
    // Add cross-rails
    translate([RACK_RAIL_WIDTH, u_to_mm(1.5), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_10_USABLE, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(4.5), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(RACK_10_USABLE, height=12, depth=15);
    
    // Add panels
    translate([RACK_RAIL_WIDTH + 15, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(6, 1);
    
    translate([RACK_RAIL_WIDTH + 70, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
    
    translate([RACK_RAIL_WIDTH + 25, u_to_mm(5), RACK_RAIL_DEPTH])
        %makerpanel(8, 1);
}

// ============================================
// TEST 6: Custom Width Rack with Panels
// ============================================

module test_custom_rack() {
    /*
    Custom width rack (useful for non-standard dimensions)
    */
    
    // Custom 36" wide rack (914mm), 6U height
    rack_custom(914, u_to_mm(6));
    
    // Add multiple cross-rails
    translate([RACK_RAIL_WIDTH, u_to_mm(1.5), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(914 - 2*RACK_RAIL_WIDTH, height=12, depth=15);
    
    translate([RACK_RAIL_WIDTH, u_to_mm(4), RACK_RAIL_DEPTH - 15])
        t_slot_crossrail(914 - 2*RACK_RAIL_WIDTH, height=12, depth=15);
    
    // Add varied panels
    translate([RACK_RAIL_WIDTH + 40, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(12, 1);
    
    translate([RACK_RAIL_WIDTH + 140, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(16, 1);
    
    translate([RACK_RAIL_WIDTH + 280, u_to_mm(2), RACK_RAIL_DEPTH])
        %makerpanel(12, 1);
    
    translate([RACK_RAIL_WIDTH + 80, u_to_mm(4.5), RACK_RAIL_DEPTH])
        %makerpanel(20, 1);
    
    translate([RACK_RAIL_WIDTH + 240, u_to_mm(4.5), RACK_RAIL_DEPTH])
        %makerpanel(16, 1);
}

// ============================================
// TEST 7: Dense Panel Arrays
// ============================================

module test_dense_array() {
    /*
    Shows multiple cross-rails stacked to create a dense panel array
    */
    
    // 48 HP wide base with 3 cross-rails stacked
    y_spacing = u_to_mm(1.5);
    
    for (rail = [0 : 2]) {
        translate([0, rail * y_spacing, 0])
            t_slot_crossrail(hp_to_mm(48), height=12, depth=15);
    }
    
    // Add panels - filling multiple rows
    current_y = y_spacing;
    
    translate([hp_to_mm(2), current_y + 20, 15])
        %makerpanel(6, 1);
    
    translate([hp_to_mm(10), current_y + 20, 15])
        %makerpanel(8, 1);
    
    translate([hp_to_mm(20), current_y + 20, 15])
        %makerpanel(8, 1);
    
    translate([hp_to_mm(30), current_y + 20, 15])
        %makerpanel(8, 1);
    
    // Second row
    current_y = 2 * y_spacing;
    
    translate([hp_to_mm(2), current_y + 20, 15])
        %makerpanel(8, 1);
    
    translate([hp_to_mm(12), current_y + 20, 15])
        %makerpanel(12, 1);
    
    translate([hp_to_mm(26), current_y + 20, 15])
        %makerpanel(8, 1);
}

// ============================================
// RENDER SELECTION WITH TEST SWITCHER
// ============================================

// Select which test(s) to render:
// Options: "all"
//          "1"     - Individual panel sizes
//          "2"     - T-slot cross-rail hosts
//          "3"     - Standalone systems
//          "4a"    - 19" Rack (small)
//          "4b"    - 19" Rack (medium)
//          "4c"    - 19" Rack (large)
//          "5a"    - 10" Rack (small)
//          "5b"    - 10" Rack (medium)
//          "6"     - Custom width rack
//          "7"     - Dense panel array
TEST_SELECT = "5a";

// Render selected tests
if (TEST_SELECT == "all" || TEST_SELECT == "1") {
    // Test 1: Individual panel sizes
    translate([0, 0, 0])
        test_panel_sizes();
}

if (TEST_SELECT == "all" || TEST_SELECT == "2") {
    // Test 2: T-slot cross-rail hosts of various widths
    translate([0, u_to_mm(12), 0])
        test_t_slot_crossrails();
}

if (TEST_SELECT == "all" || TEST_SELECT == "3") {
    // Test 3: Standalone systems
    translate([300, 0, 0])
        test_standalone_systems();
}

if (TEST_SELECT == "all" || TEST_SELECT == "4" || TEST_SELECT == "4a") {
    // Test 4a: 19" Rack (small)
    translate([0, u_to_mm(20), 0])
        test_19_rack_small();
}

if (TEST_SELECT == "all" || TEST_SELECT == "4" || TEST_SELECT == "4b") {
    // Test 4b: 19" Rack (medium)
    translate([600, u_to_mm(20), 0])
        test_19_rack_medium();
}

if (TEST_SELECT == "all" || TEST_SELECT == "4" || TEST_SELECT == "4c") {
    // Test 4c: 19" Rack (large)
    translate([1200, u_to_mm(20), 0])
        test_19_rack_large();
}

if (TEST_SELECT == "all" || TEST_SELECT == "5" || TEST_SELECT == "5a") {
    // Test 5a: 10" Rack (small)
    translate([0, u_to_mm(40), 0])
        test_10_rack_small();
}

if (TEST_SELECT == "all" || TEST_SELECT == "5" || TEST_SELECT == "5b") {
    // Test 5b: 10" Rack (medium)
    translate([400, u_to_mm(40), 0])
        test_10_rack_medium();
}

if (TEST_SELECT == "all" || TEST_SELECT == "6") {
    // Test 6: Custom width rack
    translate([0, u_to_mm(55), 0])
        test_custom_rack();
}

if (TEST_SELECT == "all" || TEST_SELECT == "7") {
    // Test 7: Dense panel array
    translate([1200, u_to_mm(55), 0])
        test_dense_array();
}
