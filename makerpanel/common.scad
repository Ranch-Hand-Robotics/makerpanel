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
T_SLOT_WIDTH = 6;           // T-slot nut width (M5/M6)
T_SLOT_LENGTH = 12;         // T-slot nut length (elongated rectangular)
T_SLOT_SPACING = 25;        // Center-to-center spacing (standard T-slot)

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
