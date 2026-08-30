#include <Arduino.h>
#include <ArduinoJson.h>
#include "protocol.h"
#include "display.h"
#include "encoder.h"

static PanelState state;
static String rxBuf;
static uint32_t lastHelloMs = 0;

static const uint32_t OFFLINE_MS = 2000;
static const uint32_t ENC_FLUSH_MS = 20;   // ~50 Hz max delta reports

static void sendJson(const JsonDocument& doc) {
    serializeJson(doc, Serial);
    Serial.println();
}

static void sendHello() {
    JsonDocument d;
    d["t"] = "hello";
    d["fw"] = FW_VERSION;
    d["dev"] = "t-encoder-pro";
    d["proto"] = PROTO_VERSION;
    sendJson(d);
}

static void handleLine(const String& line) {
    JsonDocument d;
    if (deserializeJson(d, line)) return;
    const char* t = d["t"] | "";

    if (!strcmp(t, "state")) {
        strlcpy(state.timecode, d["tc"] | "--:--:--:--", sizeof(state.timecode));
        strlcpy(state.timeline, d["tl"] | "", sizeof(state.timeline));
        strlcpy(state.mode,     d["mode"] | state.mode, sizeof(state.mode));
        state.fps     = d["fps"] | state.fps;
        state.playing = d["play"] | false;
        state.message[0] = 0;
        state.lastRxMs = millis();
    } else if (!strcmp(t, "msg")) {
        strlcpy(state.message, d["s"] | "", sizeof(state.message));
        state.lastRxMs = millis();
    } else if (!strcmp(t, "setmode")) {
        strlcpy(state.mode, d["m"] | "frame", sizeof(state.mode));
        state.lastRxMs = millis();
    } else if (!strcmp(t, "ping")) {
        JsonDocument r;
        r["t"] = "pong";
        sendJson(r);
        state.lastRxMs = millis();
    }
}

static void pumpSerial() {
    while (Serial.available()) {
        char c = Serial.read();
        if (c == '\n') { handleLine(rxBuf); rxBuf = ""; }
        else if (c != '\r' && rxBuf.length() < 512) rxBuf += c;
    }
}

void setup() {
    Serial.begin(115200);
    displayBegin();
    encoderBegin();
    sendHello();
}

void loop() {
    pumpSerial();

    static uint32_t lastFlush = 0;
    static int pending = 0;
    pending += encoderTakeDelta();

    uint32_t now = millis();
    if (pending != 0 && now - lastFlush >= ENC_FLUSH_MS) {
        JsonDocument d;
        d["t"] = "enc";
        d["d"] = pending;
        d["ms"] = now;
        sendJson(d);
        pending = 0;
        lastFlush = now;
    }

    BtnEvent ev = encoderButton();
    if (ev != BtnEvent::None) {
        if (ev == BtnEvent::Long)  buzzerBeep(1800, 40);
        if (ev == BtnEvent::Click) buzzerBeep(1200, 15);
        JsonDocument d;
        d["t"] = "btn";
        d["a"] = ev == BtnEvent::Down  ? "down"
               : ev == BtnEvent::Up    ? "up"
               : ev == BtnEvent::Click ? "click" : "long";
        sendJson(d);
    }

    // Re-announce until the host answers, so plug-in order does not matter.
    if (state.lastRxMs == 0 && now - lastHelloMs > 1000) {
        sendHello();
        lastHelloMs = now;
    }

    bool online = state.lastRxMs != 0 && (now - state.lastRxMs) < OFFLINE_MS;
    displayRender(state, online);
    delay(2);
}
