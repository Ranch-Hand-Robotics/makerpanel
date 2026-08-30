#include "encoder.h"
#include <ESP32Encoder.h>

static ESP32Encoder enc;
static int64_t lastCount = 0;
static bool lastBtn = true;          // active low
static uint32_t downAt = 0;
static bool longFired = false;
static bool armed = false;           // ignore a press held from boot (IO0 = BOOT)

static const uint32_t LONG_PRESS_MS = 600;
static const int COUNTS_PER_DETENT = 2;
static const uint8_t BUZZER_CHANNEL = 0;

void encoderBegin() {
    ESP32Encoder::useInternalWeakPullResistors = puType::up;
    enc.attachHalfQuad(PIN_ENCODER_A, PIN_ENCODER_B);
    enc.clearCount();
    pinMode(PIN_ENCODER_BTN, INPUT_PULLUP);

    ledcSetup(BUZZER_CHANNEL, 2000, 10);
    ledcAttachPin(PIN_BUZZER, BUZZER_CHANNEL);
    ledcWriteTone(BUZZER_CHANNEL, 0);
}

void buzzerBeep(uint16_t freqHz, uint16_t durationMs) {
    ledcWriteTone(BUZZER_CHANNEL, freqHz);
    delay(durationMs);
    ledcWriteTone(BUZZER_CHANNEL, 0);
}

int encoderTakeDelta() {
    int64_t now = enc.getCount();
    int64_t raw = now - lastCount;
    int detents = (int)(raw / COUNTS_PER_DETENT);
    lastCount += (int64_t)detents * COUNTS_PER_DETENT;
    return detents;
}

BtnEvent encoderButton() {
    bool now = digitalRead(PIN_ENCODER_BTN);
    uint32_t t = millis();

    if (!armed) {
        if (now) { armed = true; lastBtn = true; }
        return BtnEvent::None;
    }

    BtnEvent ev = BtnEvent::None;
    if (lastBtn && !now) {
        downAt = t; longFired = false; ev = BtnEvent::Down;
    } else if (!lastBtn && now) {
        ev = longFired ? BtnEvent::Up : BtnEvent::Click;
    } else if (!now && !longFired && (t - downAt) > LONG_PRESS_MS) {
        longFired = true; ev = BtnEvent::Long;
    }
    lastBtn = now;
    return ev;
}
