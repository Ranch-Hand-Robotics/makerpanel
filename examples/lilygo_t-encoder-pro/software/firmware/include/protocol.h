#pragma once
#include <Arduino.h>

// Wire protocol v1 - newline delimited JSON over USB CDC.
struct PanelState {
    char timecode[16] = "--:--:--:--";
    char timeline[32] = "";
    char message[32]  = "";
    int  fps          = 24;
    bool playing      = false;
    char mode[12]     = "frame";
    uint32_t lastRxMs = 0;
};

enum class BtnEvent { None, Down, Up, Click, Long };
