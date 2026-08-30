#pragma once
#include "protocol.h"

// LilyGo T-Encoder-Pro (ESP32-S3 R8) pinmap.
#define PIN_ENCODER_A   1
#define PIN_ENCODER_B   2
#define PIN_ENCODER_BTN 0
#define PIN_BUZZER      17

void encoderBegin();
int  encoderTakeDelta();     // detents since last call, sign = direction
BtnEvent encoderButton();
void buzzerBeep(uint16_t freqHz, uint16_t durationMs);
