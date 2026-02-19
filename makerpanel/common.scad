// =============================================================================
// MakerPanel System OpenSCAD Models
// Copyright (c) 2025 Ranch Hand Robotics, LLC. All rights reserved.
// Licensed under MIT License: https://opensource.org/licenses/MIT
// Modular maker panel system with T-slot rail mounting support
// All dimensions in millimeters
// =============================================================================

// ============================================
// Constants
// ============================================

// Panel Units
HP = 5.08;           // Horizontal Pitch = 5.08mm (0.200")
U = 44.45;           // Vertical Unit = 44.45mm (1.75")

// T-Slot Specifications
// Standard T-slot twist nuts (M5/M6 compatible, drop-in style)
T_SLOT_HEIGHT = 6.9;           // T-slot nut width (M5/M6)
T_SLOT_WIDTH = 5.75 * HP;      // 5.75 HP (29.06mm) avoids even 4-HP grid alignment
T_SLOT_CORNER_RADIUS = 1.0;

// Rack Specifications
RACK_SUPPORT_WIDTH = 3; 
RACK_HOLE_DIAMETER = 3.5;   // M3 mounting holes
RACK_RAIL_HEIGHT = 11; 
RACK_RAIL_THICKNESS = 3;    // Rail material thickness

// Rack Widths
RACK_19_WIDTH = 465.1;      // 19" rack outer width
RACK_10_WIDTH = 254;        // 10" rack outer width (approx)

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
