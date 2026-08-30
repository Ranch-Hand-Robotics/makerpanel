#include "display.h"

// TODO: SH8601 driver integration pending Arduino core 3.x + GFX 1.6.x.
// For now, stub out display to get firmware compiling and encoder functional.

void displayBegin() {
    // Placeholder: configure display pins and init.
    // Real init requires Arduino_GFX + SH8601 driver with compatible core.
}

void displayRender(const PanelState& s, bool online) {
    // Placeholder: render timecode, mode, status to AMOLED.
    // Will be implemented when driver support is available.
}
